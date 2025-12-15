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

  group('Container and Item End-to-End Integration Tests', () {
    late ContainerRepositorySqlite containerRepository;
    late ItemRepositorySqlite itemRepository;

    setUp(() async {
      containerRepository = ContainerRepositorySqlite();
      itemRepository = ItemRepositorySqlite();
      final dbHelper = DatabaseHelper();
      await dbHelper.database;
    });

    test('Should create a container with multiple items and verify persistence',
        () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final location = Location(
        latitude: 40.7128,
        longitude: -74.0060,
        label: 'Home Kitchen',
        address: '123 Main Street, New York, NY',
      );

      // Step 1: Create a container
      final container = Container(
        id: 'kitchen_container_$timestamp',
        name: 'Kitchen Storage_$timestamp',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: location,
        tags: ['kitchen', 'storage', 'home'],
      );

      await containerRepository.createContainer(container);

      // Fetch the created container from database
      final allContainers = await containerRepository.fetchContainers();
      final createdContainer = allContainers.firstWhere(
        (c) => c.name == 'Kitchen Storage_$timestamp',
        orElse: () => throw Exception('Container not created'),
      );

      expect(createdContainer.name, 'Kitchen Storage_$timestamp');
      expect(createdContainer.location.label, 'Home Kitchen');
      expect(createdContainer.tags, containsAll(['kitchen', 'storage']));

      // Step 2: Create multiple items in this container
      final items = [
        Item(
          id: 'item_glasses_$timestamp',
          name: 'Drinking Glasses',
          description: 'Set of 6 glass drinking cups',
          photoUrl: null,
          tags: ['glassware', 'kitchen'],
          containerId: createdContainer.id,
          externalDocumentUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Item(
          id: 'item_plates_$timestamp',
          name: 'Dinner Plates',
          description: 'Set of 12 ceramic dinner plates',
          photoUrl: null,
          tags: ['dinnerware', 'kitchen'],
          containerId: createdContainer.id,
          externalDocumentUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Item(
          id: 'item_utensils_$timestamp',
          name: 'Silverware Set',
          description: 'Complete silverware set with forks, knives, and spoons',
          photoUrl: null,
          tags: ['utensils', 'kitchen', 'silverware'],
          containerId: createdContainer.id,
          externalDocumentUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Create all items
      for (final item in items) {
        await itemRepository.createItem(item);
      }

      // Step 3: Verify all items are saved and linked to the container
      final containerItems = await itemRepository.fetchItemsByContainerId(
        createdContainer.id,
      );

      expect(containerItems.length, greaterThanOrEqualTo(3));
      expect(
        containerItems.map((i) => i.name),
        containsAll(['Drinking Glasses', 'Dinner Plates', 'Silverware Set']),
      );

      // Verify each item has correct container association
      for (final item in containerItems) {
        expect(item.containerId, createdContainer.id);
      }
    });

    test('Should update items and verify changes persist in database', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final location = Location(
        latitude: 51.5074,
        longitude: -0.1278,
        label: 'Bedroom Closet',
        address: '10 Downing Street, London',
      );

      // Create container
      final container = Container(
        id: 'closet_container_$timestamp',
        name: 'Bedroom Closet_$timestamp',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: location,
        tags: ['bedroom', 'clothing'],
      );

      await containerRepository.createContainer(container);

      final allContainers = await containerRepository.fetchContainers();
      final createdContainer = allContainers.firstWhere(
        (c) => c.name == 'Bedroom Closet_$timestamp',
      );

      // Create an item
      final originalItem = Item(
        id: 'item_shirts_$timestamp',
        name: 'T-Shirts Collection',
        description: 'Various colored t-shirts',
        photoUrl: null,
        tags: ['clothing', 'casual'],
        containerId: createdContainer.id,
        externalDocumentUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await itemRepository.createItem(originalItem);

      // Update the item
      final updatedItem = originalItem.copyWith(
        name: 'T-Shirts Collection - Updated',
        description: 'Various colored t-shirts (recently organized)',
        tags: ['clothing', 'casual', 'organized'],
      );

      await itemRepository.updateItem(updatedItem);

      // Verify update persisted
      final items = await itemRepository.fetchItemsByContainerId(createdContainer.id);
      final retrievedItem = items.firstWhere(
        (i) => i.id == 'item_shirts_$timestamp',
      );

      expect(retrievedItem.name, 'T-Shirts Collection - Updated');
      expect(
        retrievedItem.description,
        'Various colored t-shirts (recently organized)',
      );
      expect(retrievedItem.tags, contains('organized'));
    });

    test('Should move items between containers', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final location1 = Location(
        latitude: 35.6762,
        longitude: 139.6503,
        label: 'Living Room',
        address: 'Tokyo, Japan',
      );

      final location2 = Location(
        latitude: 35.6762,
        longitude: 139.6503,
        label: 'Storage Room',
        address: 'Tokyo, Japan',
      );

      // Create two containers
      final container1 = Container(
        id: 'container1_move_$timestamp',
        name: 'Living Room Box_$timestamp',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: location1,
        tags: ['living'],
      );

      final container2 = Container(
        id: 'container2_move_$timestamp',
        name: 'Storage Room Box_$timestamp',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: location2,
        tags: ['storage'],
      );

      await containerRepository.createContainer(container1);
      await containerRepository.createContainer(container2);

      final allContainers = await containerRepository.fetchContainers();
      final source = allContainers.firstWhere(
        (c) => c.name == 'Living Room Box_$timestamp',
      );
      final destination = allContainers.firstWhere(
        (c) => c.name == 'Storage Room Box_$timestamp',
      );

      // Create item in source container
      final item = Item(
        id: 'item_move_$timestamp',
        name: 'Item to Move',
        description: 'This item will be moved',
        photoUrl: null,
        tags: ['movable'],
        containerId: source.id,
        externalDocumentUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await itemRepository.createItem(item);

      // Verify item is in source
      var sourceItems = await itemRepository.fetchItemsByContainerId(source.id);
      expect(sourceItems.any((i) => i.name == 'Item to Move'), true);

      // Move item to destination
      final movedItem = item.copyWith(containerId: destination.id);
      await itemRepository.updateItem(movedItem);

      // Verify item is no longer in source
      sourceItems = await itemRepository.fetchItemsByContainerId(source.id);
      expect(sourceItems.any((i) => i.id == 'item_move_$timestamp'), false);

      // Verify item is in destination
      final destItems = await itemRepository.fetchItemsByContainerId(destination.id);
      expect(destItems.any((i) => i.id == 'item_move_$timestamp'), true);
      expect(
        destItems.firstWhere((i) => i.id == 'item_move_$timestamp').containerId,
        destination.id,
      );
    });

    test('Should handle item deletion and cleanup', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final location = Location(
        latitude: 48.8566,
        longitude: 2.3522,
        label: 'Apartment Storage',
        address: 'Paris, France',
      );

      // Create container
      final container = Container(
        id: 'storage_container_$timestamp',
        name: 'Storage Unit_$timestamp',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: location,
        tags: ['storage'],
      );

      await containerRepository.createContainer(container);

      final allContainers = await containerRepository.fetchContainers();
      final createdContainer = allContainers.firstWhere(
        (c) => c.name == 'Storage Unit_$timestamp',
      );

      // Create multiple items
      final items = [
        Item(
          id: 'delete_item_1_$timestamp',
          name: 'Item 1',
          description: null,
          photoUrl: null,
          tags: [],
          containerId: createdContainer.id,
          externalDocumentUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Item(
          id: 'delete_item_2_$timestamp',
          name: 'Item 2',
          description: null,
          photoUrl: null,
          tags: [],
          containerId: createdContainer.id,
          externalDocumentUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Item(
          id: 'delete_item_3_$timestamp',
          name: 'Item 3',
          description: null,
          photoUrl: null,
          tags: [],
          containerId: createdContainer.id,
          externalDocumentUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (final item in items) {
        await itemRepository.createItem(item);
      }

      // Verify all items exist
      var containerItems =
          await itemRepository.fetchItemsByContainerId(createdContainer.id);
      expect(containerItems.length, greaterThanOrEqualTo(3));

      // Delete one item
      await itemRepository.deleteItem('delete_item_2_$timestamp');

      // Verify item is deleted
      containerItems =
          await itemRepository.fetchItemsByContainerId(createdContainer.id);
      expect(
        containerItems.any((i) => i.id == 'delete_item_2_$timestamp'),
        false,
      );

      // Verify other items still exist
      expect(
        containerItems.map((i) => i.id),
        containsAll(['delete_item_1_$timestamp', 'delete_item_3_$timestamp']),
      );
    });

    test('Should search items by tags', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final location = Location(
        latitude: 37.7749,
        longitude: -122.4194,
        label: 'Garage',
        address: 'San Francisco, CA',
      );

      // Create container
      final container = Container(
        id: 'garage_container_$timestamp',
        name: 'Garage Storage_$timestamp',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: location,
        tags: ['garage', 'storage'],
      );

      await containerRepository.createContainer(container);

      final allContainers = await containerRepository.fetchContainers();
      final createdContainer = allContainers.firstWhere(
        (c) => c.name == 'Garage Storage_$timestamp',
      );

      // Create items with specific tags
      final items = [
        Item(
          id: 'tools_hammer_$timestamp',
          name: 'Hammer',
          description: 'Claw hammer',
          photoUrl: null,
          tags: ['tools', 'hardware'],
          containerId: createdContainer.id,
          externalDocumentUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Item(
          id: 'tools_drill_$timestamp',
          name: 'Electric Drill',
          description: 'Cordless power drill',
          photoUrl: null,
          tags: ['tools', 'power-tools'],
          containerId: createdContainer.id,
          externalDocumentUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Item(
          id: 'paint_brush_$timestamp',
          name: 'Paint Brushes',
          description: 'Various sizes',
          photoUrl: null,
          tags: ['painting', 'supplies'],
          containerId: createdContainer.id,
          externalDocumentUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (final item in items) {
        await itemRepository.createItem(item);
      }

      // Search for items with 'tools' tag
      final allItems =
          await itemRepository.fetchItemsByContainerId(createdContainer.id);
      final toolItems = allItems.where((i) => i.tags.contains('tools'));

      expect(toolItems.length, greaterThanOrEqualTo(2));
      expect(
        toolItems.map((i) => i.name),
        containsAll(['Hammer', 'Electric Drill']),
      );
    });
  });
}
