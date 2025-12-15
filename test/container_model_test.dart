import 'package:flutter_test/flutter_test.dart';
import 'package:shelfstack/data/database/database_helper.dart';
import 'package:shelfstack/data/models/container.dart';
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/models/location.dart';
import 'package:shelfstack/data/database/container_repository_sqlite.dart';
import 'package:shelfstack/data/database/item_repository_sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  setUpAll(() {
    // Initialize sqflite FFI for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Item Creation Integration Tests', () {
    late ContainerRepositorySqlite containerRepository;
    late ItemRepositorySqlite itemRepository;

    setUp(() async {
      containerRepository = ContainerRepositorySqlite();
      itemRepository = ItemRepositorySqlite();
      final dbHelper = DatabaseHelper();
      await dbHelper.database;
    });

    test('Should create an item and associate it with a container', () async {
      final location = Location(
        latitude: 30.0,
        longitude: 31.0,
        label: 'Kitchen',
        address: 'Home',
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final container = Container(
        id: 'temp_id_create_$timestamp',
        name: 'Item Test Container_$timestamp',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: location,
        tags: [],
      );

      await containerRepository.createContainer(container);

      final allContainers = await containerRepository.fetchContainers();
      final createdContainer = allContainers.firstWhere(
        (c) => c.name == 'Item Test Container_$timestamp',
      );

      final item = Item(
        id: 'test_item_create_$timestamp',
        name: 'Test Kitchen Utensil_$timestamp',
        description: 'A test utensil for the kitchen',
        photoUrl: null,
        tags: ['kitchen', 'utensil'],
        containerId: createdContainer.id,
        externalDocumentUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await itemRepository.createItem(item);

      final items = await itemRepository.fetchItemsByContainerId(createdContainer.id);
      final createdItem = items.firstWhere(
        (i) => i.name == 'Test Kitchen Utensil_$timestamp',
        orElse: () => throw Exception('Item not found in container'),
      );

      expect(createdItem.name, 'Test Kitchen Utensil_$timestamp');
      expect(createdItem.containerId, createdContainer.id);
      expect(createdItem.tags, containsAll(['kitchen', 'utensil']));
    });

    test('Should update an item in the database', () async {
      // Create a container first
      final location = Location(
        latitude: 30.0,
        longitude: 31.0,
        label: 'Kitchen',
        address: 'Home',
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final container = Container(
        id: 'temp_id_update_$timestamp',
        name: 'Update Test Container_$timestamp',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: location,
        tags: [],
      );

      await containerRepository.createContainer(container);

      final allContainers = await containerRepository.fetchContainers();
      final createdContainer = allContainers.firstWhere(
        (c) => c.name == 'Update Test Container_$timestamp',
      );

      final item = Item(
        id: 'test_item_update_$timestamp',
        name: 'Original Name_$timestamp',
        description: 'Original description',
        photoUrl: null,
        tags: ['tag1'],
        containerId: createdContainer.id,
        externalDocumentUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await itemRepository.createItem(item);

      var items = await itemRepository.fetchItemsByContainerId(createdContainer.id);
      final createdItem = items.firstWhere((i) => i.name == 'Original Name_$timestamp');

      final updatedItem = createdItem.copyWith(
        name: 'Updated Name_$timestamp',
        description: 'Updated description',
        tags: ['tag1', 'tag2'],
      );
      await itemRepository.updateItem(updatedItem);

      items = await itemRepository.fetchItemsByContainerId(createdContainer.id);
      final retrieved = items.firstWhere((i) => i.id == createdItem.id);

      expect(retrieved.name, 'Updated Name_$timestamp');
      expect(retrieved.description, 'Updated description');
      expect(retrieved.tags, contains('tag2'));
    });

    test('Should delete an item from the database', () async {
      final location = Location(
        latitude: 30.0,
        longitude: 31.0,
        label: 'Kitchen',
        address: 'Home',
      );

      final container = Container(
        id: 'temp_id_delete_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Delete Test Container_${DateTime.now().millisecondsSinceEpoch}',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: location,
        tags: [],
      );

      await containerRepository.createContainer(container);

      final allContainers = await containerRepository.fetchContainers();
      final createdContainer = allContainers.firstWhere(
        (c) => c.name.startsWith('Delete Test Container_'),
      );

      final item = Item(
        id: 'temp_id_delete_item_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Item to Delete_${DateTime.now().millisecondsSinceEpoch}',
        description: null,
        photoUrl: null,
        tags: [],
        containerId: createdContainer.id,
        externalDocumentUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await itemRepository.createItem(item);

      var items = await itemRepository.fetchItemsByContainerId(createdContainer.id);
      final createdItem = items.firstWhere((i) => i.name.startsWith('Item to Delete_'));

      await itemRepository.deleteItem(createdItem.id);

      items = await itemRepository.fetchItemsByContainerId(createdContainer.id);
      final exists = items.any((i) => i.id == createdItem.id);

      expect(exists, false);
    });

    test('Should retrieve multiple items from a container', () async {
      final location = Location(
        latitude: 30.0,
        longitude: 31.0,
        label: 'Kitchen',
        address: 'Home',
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final container = Container(
        id: 'temp_id_multi_$timestamp',
        name: 'Multi Item Container_$timestamp',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: location,
        tags: [],
      );

      await containerRepository.createContainer(container);

      final allContainers = await containerRepository.fetchContainers();
      final createdContainer = allContainers.firstWhere(
        (c) => c.name.startsWith('Multi Item Container_'),
      );

      final item1 = Item(
        id: 'temp_id_multi_1_$timestamp',
        name: 'First Item_$timestamp',
        description: null,
        photoUrl: null,
        tags: ['item1'],
        containerId: createdContainer.id,
        externalDocumentUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final item2 = Item(
        id: 'temp_id_multi_2_$timestamp',
        name: 'Second Item_$timestamp',
        description: null,
        photoUrl: null,
        tags: ['item2'],
        containerId: createdContainer.id,
        externalDocumentUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await itemRepository.createItem(item1);
      await itemRepository.createItem(item2);

      final items = await itemRepository.fetchItemsByContainerId(createdContainer.id);

      expect(items.length, greaterThanOrEqualTo(2));
      final itemNames = items.map((i) => i.name).toList();
      expect(
        itemNames.any((n) => n.startsWith('First Item_')),
        true,
      );
      expect(
        itemNames.any((n) => n.startsWith('Second Item_')),
        true,
      );
    });
  });
}
