import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shelfstack/data/datasources/database_seeder.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'shelfstack.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS item_documents');
        await db.execute('DROP TABLE IF EXISTS item_tags');
        await db.execute('DROP TABLE IF EXISTS items');
        await db.execute('DROP TABLE IF EXISTS container_tags');
        await db.execute('DROP TABLE IF EXISTS containers');

        await _onCreate(db, newVersion);
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE containers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        photo_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        location_latitude REAL NOT NULL,
        location_longitude REAL NOT NULL,
        location_label TEXT NOT NULL,
        location_address TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE container_tags (
        container_id TEXT NOT NULL,
        tag TEXT NOT NULL,
        PRIMARY KEY (container_id, tag),
        FOREIGN KEY (container_id) REFERENCES containers(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        photo_url TEXT,
        container_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (container_id) REFERENCES containers(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE item_tags (
        item_id TEXT NOT NULL,
        tag TEXT NOT NULL,
        PRIMARY KEY (item_id, tag),
        FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE item_documents (
        id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        name TEXT NOT NULL,
        url TEXT NOT NULL,
        FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
      )
    ''');

    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');

    // Seed initial data
    if (kDebugMode) {
      await DatabaseSeeder.seed(db);
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
