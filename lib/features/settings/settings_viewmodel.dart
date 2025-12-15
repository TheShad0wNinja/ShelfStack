import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelfstack/data/database/database_helper.dart';

class SettingsViewModel extends ChangeNotifier {
  static const String _usernameKey = 'username';
  String _username = 'User';
  String get username => _username;

  String _tempUsername = 'User';
  String get tempUsername => _tempUsername;

  bool _hasUnsavedChanges = false;
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? _lastExportPath;
  String? get lastExportPath => _lastExportPath;

  bool _lastExportIncludedImages = false;
  bool get lastExportIncludedImages => _lastExportIncludedImages;

  int _importedImagesCount = 0;
  int get importedImagesCount => _importedImagesCount;

  SettingsViewModel() {
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString(_usernameKey) ?? 'User';
    _tempUsername = _username;
    notifyListeners();
  }

  void updateTempUsername(String newName) {
    _tempUsername = newName.trim();
    _hasUnsavedChanges = _tempUsername != _username;
    notifyListeners();
  }

  Future<bool> saveUsername() async {
    if (_tempUsername.isEmpty) {
      _error = 'Name cannot be empty';
      notifyListeners();
      return false;
    }

    _username = _tempUsername;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, _username);
    _hasUnsavedChanges = false;
    _error = null;
    notifyListeners();
    return true;
  }

  void discardChanges() {
    _tempUsername = _username;
    _hasUnsavedChanges = false;
    _error = null;
    notifyListeners();
  }

  Future<bool> exportDatabase() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final dbFilePath = await DatabaseHelper().getDatabaseFilePath();
      final dbFile = File(dbFilePath);

      if (!await dbFile.exists()) {
        _error = 'Database file not found';
        return false;
      }

      final appDocDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(appDocDir.path, 'itemImages'));

      final archive = Archive();

      final dbBytes = await dbFile.readAsBytes();
      archive.addFile(ArchiveFile('shelfstack.db', dbBytes.length, dbBytes));

      final imagesExist = await imagesDir.exists();
      if (imagesExist) {
        final files = imagesDir.listSync(recursive: true);
        for (final f in files) {
          if (f is File) {
            final rel = p.relative(f.path, from: imagesDir.path);
            final bytes = await f.readAsBytes();
            archive.addFile(ArchiveFile(p.join('itemImages', rel), bytes.length, bytes));
          }
        }
      }

      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);
      if (zipData == null || zipData.isEmpty) {
        _error = 'Export failed: could not encode zip';
        return false;
      }

      final fileName = 'shelfstack_backup_${DateTime.now().millisecondsSinceEpoch}.zip';

      // Offer save dialog and provide bytes. On Android SAF the returned path
      // may be a content URI that is not directly writable by File APIs. The
      // FilePicker will write the bytes for us when `bytes` is provided, so
      // avoid copying to the returned path. Instead, consider the save
      // successful if a non-null path is returned.
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup (zip)',
        fileName: fileName,
        allowedExtensions: ['zip'],
        type: FileType.custom,
        bytes: Uint8List.fromList(zipData),
      );

      if (savePath == null) {
        // User cancelled
        return false;
      }

      // If the returned path points to a real file on disk, verify it.
      final savedFile = File(savePath);
      if (await savedFile.exists() && (await savedFile.length()) > 0) {
        _lastExportPath = savePath;
        _lastExportIncludedImages = imagesExist;
        return true;
      }

      // Fallback: assume FilePicker handled writing (common on Android SAF)
      _lastExportPath = savePath;
      _lastExportIncludedImages = imagesExist;
      return true;
    } catch (e) {
      _error = 'Export failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> importDatabase() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Backup (.zip)',
        type: FileType.custom,
        allowedExtensions: ['zip'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return false;

      final picked = result.files.single;

      // Prepare a local temporary file for the zip (support bytes-only picks)
      final tempDir = await getTemporaryDirectory();
      final tmpZip = File(p.join(tempDir.path, 'shelfstack_import_${DateTime.now().millisecondsSinceEpoch}.zip'));

      if (picked.path != null && picked.path!.isNotEmpty) {
        // If a real path was provided, copy it to temp so we can extract safely
        await File(picked.path!).copy(tmpZip.path);
      } else if (picked.bytes != null) {
        await tmpZip.writeAsBytes(picked.bytes!);
      } else {
        _error = 'No valid backup selected';
        return false;
      }

      // Close existing database connection
      await DatabaseHelper().close();

      final extractDir = Directory(p.join(tempDir.path, 'shelfstack_import_${DateTime.now().millisecondsSinceEpoch}'));
      await extractDir.create(recursive: true);

      // Extract zip
      try {
        final zipDecoder = ZipDecoder();
        final bytes = await tmpZip.readAsBytes();
        final archive = zipDecoder.decodeBytes(bytes);
        for (final file in archive) {
          final filename = file.name;
          final outPath = p.join(extractDir.path, filename);
          if (file.isFile) {
            final outFile = File(outPath);
            await outFile.create(recursive: true);
            await outFile.writeAsBytes(file.content as List<int>);
          } else {
            await Directory(outPath).create(recursive: true);
          }
        }
      } catch (e) {
        _error = 'Failed to extract backup: $e';
        return false;
      } finally {
        try {
          if (await tmpZip.exists()) await tmpZip.delete();
        } catch (_) {}
      }

      // Find .db file in extracted files
      final extractedDb = extractDir
          .listSync(recursive: true)
          .whereType<File>()
          .firstWhere((f) => f.path.toLowerCase().endsWith('.db'), orElse: () => File(''));

      if (!await extractedDb.exists()) {
        _error = 'No database file found in backup';
        return false;
      }

      final targetDbPath = await DatabaseHelper().getDatabaseFilePath();

      // Replace DB file atomically: delete if exists then copy
      try {
        final targetDbFile = File(targetDbPath);
        if (await targetDbFile.exists()) {
          await targetDbFile.delete();
        }
        await extractedDb.copy(targetDbPath);
      } catch (e) {
        _error = 'Failed to restore database: $e';
        return false;
      }

      // Copy images if present
      _importedImagesCount = 0;
      final appDocDir = await getApplicationDocumentsDirectory();
      final targetImagesDir = Directory(p.join(appDocDir.path, 'itemImages'));
      await targetImagesDir.create(recursive: true);

      final extractedImagesDir = extractDir
          .listSync(recursive: true)
          .whereType<Directory>()
          .firstWhere((d) => p.basename(d.path) == 'itemImages', orElse: () => Directory(''));

      if (extractedImagesDir is Directory && await extractedImagesDir.exists()) {
        for (final f in extractedImagesDir.listSync(recursive: true)) {
          if (f is File) {
            final rel = p.relative(f.path, from: extractedImagesDir.path);
            final dest = File(p.join(targetImagesDir.path, rel));
            await dest.parent.create(recursive: true);
            await f.copy(dest.path);
            _importedImagesCount++;
          }
        }
      }

      // Cleanup extracted files
      try {
        if (await extractDir.exists()) {
          await extractDir.delete(recursive: true);
        }
      } catch (_) {}

      return true;
    } catch (e) {
      _error = 'Import failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
