import 'dart:async';

import 'package:shelfstack/data/database/database_helper.dart';
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';
import 'package:sqflite/sqflite.dart';

class ItemRepositorySqlite implements ItemRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _streamController = StreamController<void>.broadcast();

  @override
  Stream<void> get onDataChanged => _streamController.stream;

  @override
  Future<List<Item>> fetchItemsByContainerId(String containerId) async {
    final db = await _dbHelper.database;

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

  @override
  Future<Item> fetchItemById(String id) async {
    final db = await _dbHelper.database;

    final itemMaps = await db.query('items', where: 'id = ?', whereArgs: [id]);

    if (itemMaps.isEmpty) {
      throw Exception('Item not found');
    }

    final itemMap = itemMaps.first;

    final tagMaps = await db.query(
      'item_tags',
      where: 'item_id = ?',
      whereArgs: [id],
    );
    final tags = tagMaps.map((t) => t['tag'] as String).toList();

    return Item.fromJson(itemMap, tags);
  }

  @override
  Future createItem(Item item) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // Insert item
      await txn.insert('items', item.toJson());

      // Insert tags
      for (final tag in item.tags) {
        await txn.insert('item_tags', {'item_id': item.id, 'tag': tag});
      }
    });
    _streamController.add(null);
  }

  @override
  Future updateItem(Item item) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // Update item
      await txn.update(
        'items',
        item.toJson(),
        where: 'id = ?',
        whereArgs: [item.id],
      );

      // Delete old tags
      await txn.delete('item_tags', where: 'item_id = ?', whereArgs: [item.id]);

      // Insert new tags
      for (final tag in item.tags) {
        await txn.insert('item_tags', {'item_id': item.id, 'tag': tag});
      }
    });
    _streamController.add(null);
  }

  @override
  Future deleteItem(String id) async {
    final db = await _dbHelper.database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
    _streamController.add(null);
  }

  @override
  Future<List<Item>> searchItems(String query) async {
    if (query.isEmpty) {
      final db = await _dbHelper.database;
      final itemMaps = await db.query('items');

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

    final db = await _dbHelper.database;
    final lowerQuery = query.toLowerCase();

    // Search in items table
    final itemMaps = await db.query(
      'items',
      where: '''
        LOWER(name) LIKE ? OR 
        LOWER(description) LIKE ?
      ''',
      whereArgs: ['%$lowerQuery%', '%$lowerQuery%'],
    );

    // Also search in tags
    final tagMaps = await db.rawQuery(
      '''
      SELECT DISTINCT item_id 
      FROM item_tags 
      WHERE LOWER(tag) LIKE ?
    ''',
      ['%$lowerQuery%'],
    );

    final itemIdsFromTags = tagMaps.map((t) => t['item_id'] as String).toSet();

    final List<Item> items = [];
    final processedIds = <String>{};

    // Process items from direct search
    for (final itemMap in itemMaps) {
      final id = itemMap['id'] as String;
      if (processedIds.contains(id)) continue;
      processedIds.add(id);

      final tagMaps = await db.query(
        'item_tags',
        where: 'item_id = ?',
        whereArgs: [id],
      );
      final tags = tagMaps.map((t) => t['tag'] as String).toList();

      items.add(Item.fromJson(itemMap, tags));
    }

    // Process items from tag search
    for (final id in itemIdsFromTags) {
      if (processedIds.contains(id)) continue;
      processedIds.add(id);

      final itemMaps = await db.query(
        'items',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (itemMaps.isEmpty) continue;

      final itemMap = itemMaps.first;

      final tagMaps = await db.query(
        'item_tags',
        where: 'item_id = ?',
        whereArgs: [id],
      );
      final tags = tagMaps.map((t) => t['tag'] as String).toList();

      items.add(Item.fromJson(itemMap, tags));
    }

    return items;
  }

  @override
  Future<int> fetchTotalItemCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM items');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future assignItemToContainer(String itemId, String containerId) async {
    final db = await _dbHelper.database;

    // Verify container exists
    final containerMaps = await db.query(
      'containers',
      where: 'id = ?',
      whereArgs: [containerId],
    );

    if (containerMaps.isEmpty) {
      throw Exception('Container not found');
    }

    // Update item's container_id
    await db.update(
      'items',
      {
        'container_id': containerId,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [itemId],
    );

    _streamController.add(null);
  }

  @override
  Future moveItemToContainer(
    String itemId,
    String fromContainerId,
    String toContainerId,
  ) async {
    final db = await _dbHelper.database;

    // Verify item exists and is in the source container
    final itemMaps = await db.query(
      'items',
      where: 'id = ? AND container_id = ?',
      whereArgs: [itemId, fromContainerId],
    );

    if (itemMaps.isEmpty) {
      throw Exception('Item not found in source container');
    }

    // Verify destination container exists
    final containerMaps = await db.query(
      'containers',
      where: 'id = ?',
      whereArgs: [toContainerId],
    );

    if (containerMaps.isEmpty) {
      throw Exception('Destination container not found');
    }

    // Move item
    await db.update(
      'items',
      {
        'container_id': toContainerId,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [itemId],
    );

    _streamController.add(null);
  }
}
