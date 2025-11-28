import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
      final path = '$dbPath/shelfstack.db';
      final dbFile = File(path);

      if (!await dbFile.exists()) {
        _error = 'Database file not found';
        return false;
      }

      // Use FilePicker to select where to save
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Database Backup',
        fileName:
            'shelfstack_backup_${DateTime.now().millisecondsSinceEpoch}.db',
        allowedExtensions: ['db'],
        type: FileType.any,
      );

      if (outputFile == null) {
        // User canceled
        return false;
      }

      await dbFile.copy(outputFile);
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
        dialogTitle: 'Select Database Backup',
        type: FileType
            .any, // .db extension might not be recognized on all platforms
      );

      if (result == null || result.files.single.path == null) {
        return false;
      }

      final importPath = result.files.single.path!;

      // Close existing database connection
      await DatabaseHelper().close();

      final dbPath = await getDatabasesPath();
      final path = '$dbPath/shelfstack.db';

      // Backup current db just in case? Maybe later.

      // Copy imported file to db location
      await File(importPath).copy(path);

      // Re-open database (DatabaseHelper handles lazy opening)

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
