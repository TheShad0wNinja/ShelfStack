import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelfstack/data/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

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
      // Request storage permissions if needed (Android 10+ usually doesn't need for picking, but for saving maybe)
      // For simplicity, we'll try to pick a directory or save file.
      // FilePicker saveFile is only for desktop usually or specific mobile versions.
      // Let's use getExternalStorageDirectory or similar for Android if we want to save to a specific place,
      // but picking a directory is better.

      // Actually, on mobile, it's easier to share the file or save to Downloads.
      // Let's try to get the database path first.
      final dbPath = await getDatabasesPath();
      final dbFilePath = p.join(dbPath, 'shelfstack.db');
      final dbFile = File(dbFilePath);

      if (!await dbFile.exists()) {
        _error = 'Database file not found';
        return false;
      }

      final appDocDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(appDocDir.path, 'itemImages'));

      // Ask user where to save zip
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup (zip)',
        fileName: 'shelfstack_backup_${DateTime.now().millisecondsSinceEpoch}.zip',
        allowedExtensions: ['zip'],
        type: FileType.custom,
      );

      if (outputFile == null) return false;

      // Build archive manually to avoid platform-specific ZipFileEncoder issues
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
      if (zipData == null) {
        _error = 'Export failed: could not encode zip';
        return false;
      }

      await File(outputFile).writeAsBytes(zipData);

      _lastExportPath = outputFile;
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
      );

      if (result == null || result.files.single.path == null) return false;

      final importPath = result.files.single.path!;

      // Close existing database connection
      await DatabaseHelper().close();

      final tempDir = await getTemporaryDirectory();
      final extractDir = Directory(p.join(tempDir.path, 'shelfstack_import_${DateTime.now().millisecondsSinceEpoch}'));
      await extractDir.create(recursive: true);

      // Extract zip
      try {
        final zipDecoder = ZipDecoder();
        final bytes = File(importPath).readAsBytesSync();
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

      final dbPath = await getDatabasesPath();
      final targetDbPath = p.join(dbPath, 'shelfstack.db');

      // Copy DB
      await extractedDb.copy(targetDbPath);

      // Copy images if present
      _importedImagesCount = 0;
      final appDocDir = await getApplicationDocumentsDirectory();
      final targetImagesDir = Directory(p.join(appDocDir.path, 'itemImages'));
      await targetImagesDir.create(recursive: true);

      final extractedImagesDir = extractDir.listSync().firstWhere(
        (e) => e is Directory && p.basename(e.path) == 'itemImages',
        orElse: () => Directory(''),
      );

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
