import 'dart:async';

import 'package:shelfstack/data/database/database_helper.dart';
import 'package:shelfstack/data/models/container.dart';
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class ContainerRepositorySqlite implements ContainerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _streamController = StreamController<void>.broadcast();
  static final _uuid = Uuid();

  @override
  Stream<void> get onDataChanged => _streamController.stream;

  @override
  Future<List<Container>> fetchContainers() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> containerMaps = await db.query(
      'containers',
      orderBy: 'updated_at DESC',
    );

    final List<Container> containers = [];

    for (final containerMap in containerMaps) {
      // Fetch tags for this container
      final tagMaps = await db.query(
        'container_tags',
        where: 'container_id = ?',
        whereArgs: [containerMap['id']],
      );
      final tags = tagMaps.map((t) => t['tag'] as String).toList();

      // Fetch items for this container
      final items = await _fetchItemsForContainer(
        db,
        containerMap['id'] as String,
      );

      containers.add(Container.fromJson(containerMap, tags, items));
    }

    return containers;
  }

  @override
  Future<Container> fetchContainerById(String id) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> containerMaps = await db.query(
      'containers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (containerMaps.isEmpty) {
      throw Exception('Container not found');
    }

    final containerMap = containerMaps.first;

    // Fetch tags
    final tagMaps = await db.query(
      'container_tags',
      where: 'container_id = ?',
      whereArgs: [id],
    );
    final tags = tagMaps.map((t) => t['tag'] as String).toList();

    // Fetch items
    final items = await _fetchItemsForContainer(db, id);

    return Container.fromJson(containerMap, tags, items);
  }

  @override
  Future createContainer(Container container) async {
    final db = await _dbHelper.database;

    // Assign the container a UUIDv4 id
    final containerWithId = container.copyWith(id: _uuid.v4());

    await db.transaction((txn) async {
      await txn.insert('containers', containerWithId.toJson());

      // Insert tags
      for (final tag in containerWithId.tags) {
        await txn.insert('container_tags', {
          'container_id': containerWithId.id,
          'tag': tag,
        });
      }
    });

    _streamController.add(null); // Notify listeners
  }

  @override
  Future updateContainer(Container container) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // Update container
      await txn.update(
        'containers',
        container.copyWith(updatedAt: DateTime.now()).toJson(),
        where: 'id = ?',
        whereArgs: [container.id],
      );

      // Delete old tags
      await txn.delete(
        'container_tags',
        where: 'container_id = ?',
        whereArgs: [container.id],
      );

      // Insert new tags
      for (final tag in container.tags) {
        await txn.insert('container_tags', {
          'container_id': container.id,
          'tag': tag,
        });
      }
    });

    _streamController.add(null);
  }

  @override
  Future deleteContainer(String id) async {
    final db = await _dbHelper.database;
    await db.delete('containers', where: 'id = ?', whereArgs: [id]);

    _streamController.add(null);
  }

  @override
  Future<List<Container>> searchContainers(String query) async {
    if (query.isEmpty) return fetchContainers();

    final db = await _dbHelper.database;
    final lowerQuery = query.toLowerCase();

    // Search in containers table
    final containerMaps = await db.query(
      'containers',
      where: '''
        LOWER(name) LIKE ? OR 
        LOWER(location_label) LIKE ? OR 
        LOWER(location_address) LIKE ?
      ''',
      whereArgs: ['%$lowerQuery%', '%$lowerQuery%', '%$lowerQuery%'],
    );

    // Also search in tags
    final tagMaps = await db.rawQuery(
      '''
      SELECT DISTINCT container_id 
      FROM container_tags 
      WHERE LOWER(tag) LIKE ?
    ''',
      ['%$lowerQuery%'],
    );

    final containerIdsFromTags = tagMaps
        .map((t) => t['container_id'] as String)
        .toSet();

    final List<Container> containers = [];
    final processedIds = <String>{};

    // Process containers from direct search
    for (final containerMap in containerMaps) {
      final id = containerMap['id'] as String;
      if (processedIds.contains(id)) continue;
      processedIds.add(id);

      final tagMaps = await db.query(
        'container_tags',
        where: 'container_id = ?',
        whereArgs: [id],
      );
      final tags = tagMaps.map((t) => t['tag'] as String).toList();

      final items = await _fetchItemsForContainer(db, id);

      containers.add(Container.fromJson(containerMap, tags, items));
    }

    // Process containers from tag search
    for (final id in containerIdsFromTags) {
      if (processedIds.contains(id)) continue;
      processedIds.add(id);

      final containerMaps = await db.query(
        'containers',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (containerMaps.isEmpty) continue;

      final containerMap = containerMaps.first;

      final tagMaps = await db.query(
        'container_tags',
        where: 'container_id = ?',
        whereArgs: [id],
      );
      final tags = tagMaps.map((t) => t['tag'] as String).toList();

      final items = await _fetchItemsForContainer(db, id);

      containers.add(Container.fromJson(containerMap, tags, items));
    }

    return containers;
  }

  @override
  Future<int> fetchTotalContainerCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM containers',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<List<Container>> fetchRecentContainers(int amount) async {
    final db = await _dbHelper.database;

    final containerMaps = await db.query(
      'containers',
      orderBy: 'updated_at DESC',
      limit: amount,
    );

    final List<Container> containers = [];

    for (final containerMap in containerMaps) {
      final tagMaps = await db.query(
        'container_tags',
        where: 'container_id = ?',
        whereArgs: [containerMap['id']],
      );
      final tags = tagMaps.map((t) => t['tag'] as String).toList();

      final items = await _fetchItemsForContainer(
        db,
        containerMap['id'] as String,
      );

      containers.add(Container.fromJson(containerMap, tags, items));
    }

    return containers;
  }

  Future<List<Item>> _fetchItemsForContainer(
    Database db,
    String containerId,
  ) async {
    final itemMaps = await db.query(
      'items',
      where: 'container_id = ?',
      whereArgs: [containerId],
    );

    final List<Item> items = [];

    for (final itemMap in itemMaps) {
      final tagMaps = await db.query(
        'item_tags',
        where: 'item_id = ?',
        whereArgs: [itemMap['id']],
      );
      final tags = tagMaps.map((t) => t['tag'] as String).toList();

      items.add(Item.fromJson(itemMap, tags));
    }

    return items;
  }
}
