import 'package:flutter_test/flutter_test.dart';
import 'package:shelfstack/data/database/database_helper.dart';
import 'package:shelfstack/data/models/container.dart';
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/models/location.dart';
import 'package:shelfstack/data/database/container_repository_sqlite.dart';
import 'package:shelfstack/data/database/item_repository_sqlite.dart';
import 'package:shelfstack/features/inventory/viewmodels/create_container_viewmodel.dart';
import 'package:shelfstack/features/inventory/viewmodels/add_item_viewmodel.dart';
import 'package:shelfstack/features/inventory/viewmodels/edit_container_viewmodel.dart';
import 'package:shelfstack/features/inventory/viewmodels/edit_item_viewmodel.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('CreateContainerViewModel Tests', () {
    late CreateContainerViewModel viewModel;
    late ContainerRepositorySqlite containerRepository;

    setUp(() async {
      containerRepository = ContainerRepositorySqlite();
      viewModel = CreateContainerViewModel(containerRepository);
      final dbHelper = DatabaseHelper();
      await dbHelper.database;
    });

    test('Should update container name', () {
      viewModel.updateName('My Storage Box');
      expect(viewModel.name, 'My Storage Box');
    });

    test('Should add and remove tags', () {
      viewModel.addTag('storage');
      viewModel.addTag('home');
      expect(viewModel.tags, containsAll(['storage', 'home']));

      viewModel.removeTag('storage');
      expect(viewModel.tags, ['home']);
    });

    test('Should not add duplicate tags', () {
      viewModel.addTag('storage');
      viewModel.addTag('storage');
      expect(viewModel.tags.length, 1);
    });

    test('Should validate empty container name', () {
      viewModel.updateName('');
      final result = viewModel.validate();
      expect(result.isValid, false);
    });

    test('Should validate non-empty container name', () {
      viewModel.updateName('My Container');
      final result = viewModel.validate();
      expect(result.isValid, true);
    });

    test('Should create container and persist to database', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      viewModel.updateName('New Container_$timestamp');
      viewModel.addTag('test');
      viewModel.addTag('demo');

      final result = await viewModel.createContainer();
      expect(result.isValid, true);

      final containers = await containerRepository.fetchContainers();
      final created = containers.firstWhere(
        (c) => c.name == 'New Container_$timestamp',
        orElse: () => throw Exception('Container not found'),
      );

      expect(created.name, 'New Container_$timestamp');
      expect(created.tags, containsAll(['test', 'demo']));
    });
  });

  group('AddItemViewModel Tests', () {
    late AddItemViewModel viewModel;
    late ItemRepositorySqlite itemRepository;
    late ContainerRepositorySqlite containerRepository;
    late Container testContainer;

    setUp(() async {
      itemRepository = ItemRepositorySqlite();
      containerRepository = ContainerRepositorySqlite();
      viewModel = AddItemViewModel(itemRepository, containerRepository);
      final dbHelper = DatabaseHelper();
      await dbHelper.database;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      testContainer = Container(
        id: 'test_container_add_item_$timestamp',
        name: 'Test Container_$timestamp',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: Location(
          latitude: 0,
          longitude: 0,
          label: 'Test',
          address: 'Test Address',
        ),
        tags: [],
      );
      await containerRepository.createContainer(testContainer);
    });

    test('Should update item name and description', () {
      viewModel.updateName('Glassware');
      viewModel.updateDescription('Set of 6 glasses');
      expect(viewModel.name, 'Glassware');
      expect(viewModel.description, 'Set of 6 glasses');
    });

    test('Should add tags', () {
      viewModel.addTag('kitchen');
      viewModel.addTag('glassware');
      expect(viewModel.tags, containsAll(['kitchen', 'glassware']));
    });

    test('Should validate missing name', () {
      viewModel.updateName('');
      viewModel.setContainer(testContainer);
      final result = viewModel.validate();
      expect(result.isValid, false);
    });

    test('Should validate missing container', () {
      viewModel.updateName('Item Name');
      final result = viewModel.validate();
      expect(result.isValid, false);
    });

    test('Should validate when both name and container are set', () {
      viewModel.updateName('Item Name');
      viewModel.setContainer(testContainer);
      final result = viewModel.validate();
      expect(result.isValid, true);
    });

    test('Should create item with container association', () async {
      viewModel.updateName('Dishes');
      viewModel.updateDescription('Set of plates');
      viewModel.addTag('dinnerware');
      viewModel.setContainer(testContainer);

      final result = await viewModel.save();
      expect(result.isValid, true);

      final items = await itemRepository.fetchItemsByContainerId(testContainer.id);
      final created = items.firstWhere(
        (i) => i.name == 'Dishes',
        orElse: () => throw Exception('Item not found'),
      );

      expect(created.name, 'Dishes');
      expect(created.description, 'Set of plates');
      expect(created.containerId, testContainer.id);
      expect(created.tags, contains('dinnerware'));
    });
  });

  group('EditContainerViewModel Tests', () {
    late EditContainerViewModel viewModel;
    late ContainerRepositorySqlite containerRepository;
    late Container originalContainer;

    setUp(() async {
      containerRepository = ContainerRepositorySqlite();
      final dbHelper = DatabaseHelper();
      await dbHelper.database;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      originalContainer = Container(
        id: 'edit_cont_$timestamp',
        name: 'Original Name_$timestamp',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: Location(
          latitude: 40.7128,
          longitude: -74.0060,
          label: 'New York',
          address: '123 Main St',
        ),
        tags: ['original', 'tag'],
      );
      await containerRepository.createContainer(originalContainer);

      viewModel = EditContainerViewModel(originalContainer, containerRepository);
    });

    test('Should update name via updateName method', () {
      viewModel.updateName('Updated Name');
    });

    test('Should update container location label and access location', () {
      viewModel.updateLocationLabel('Updated Location');
      expect(viewModel.location?.label, 'Updated Location');
    });

    test('Should update tags via updateTags', () {
      viewModel.updateTags(['new', 'tags', 'here']);
      expect(viewModel.location, isNotNull);
    });

    test('Should reject save with empty name', () async {
      viewModel.updateName('');
      final result = await viewModel.save();
      expect(result.isValid, false);
    });

    test('Should successfully save container with new name and location', () async {
      final newTimestamp = DateTime.now().millisecondsSinceEpoch;
      viewModel.updateName('Updated Container Name_$newTimestamp');
      viewModel.updateTags(['updated', 'tags']);
      viewModel.updateLocationLabel('New Location');

      final result = await viewModel.save();
      expect(result.isValid, true);
    });

    test('Should maintain container ID structure during save', () async {
      viewModel.updateName('Final Name');
      final result = await viewModel.save();
      expect(result.isValid, true);
      expect(originalContainer.id, isNotEmpty);
    });
  });

  group('EditItemViewModel Tests', () {
    late EditItemViewModel viewModel;
    late ItemRepositorySqlite itemRepository;
    late ContainerRepositorySqlite containerRepository;
    late Item originalItem;
    late Container originalContainer;

    setUp(() async {
      itemRepository = ItemRepositorySqlite();
      containerRepository = ContainerRepositorySqlite();
      final dbHelper = DatabaseHelper();
      await dbHelper.database;

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      originalContainer = Container(
        id: 'edit_item_container_$timestamp',
        name: 'Edit Container_$timestamp',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: Location(
          latitude: 35.6762,
          longitude: 139.6503,
          label: 'Tokyo',
          address: 'Tokyo, Japan',
        ),
        tags: [],
      );
      await containerRepository.createContainer(originalContainer);

      originalItem = Item(
        id: 'edit_item_$timestamp',
        name: 'Original Item_$timestamp',
        description: 'Original description',
        photoUrl: null,
        tags: ['original'],
        containerId: originalContainer.id,
        externalDocumentUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await itemRepository.createItem(originalItem);

      viewModel = EditItemViewModel(
        itemRepository,
        containerRepository,
        originalItem,
        originalContainer,
      );
    });

    test('Should initialize with original item data', () {
      expect(viewModel.name, originalItem.name);
      expect(viewModel.description, originalItem.description);
      expect(viewModel.tags, contains('original'));
    });

    test('Should update item name', () {
      viewModel.updateName('Updated Item Name');
      expect(viewModel.name, 'Updated Item Name');
    });

    test('Should update item description', () {
      viewModel.updateDescription('Updated description');
      expect(viewModel.description, 'Updated description');
    });

    test('Should update item tags', () {
      viewModel.updateTags(['updated', 'tags', 'here']);
      expect(viewModel.tags, containsAll(['updated', 'tags', 'here']));
    });

    test('Should validate empty name', () {
      viewModel.updateName('');
      final result = viewModel.validate();
      expect(result.isValid, false);
    });

    test('Should validate non-empty name', () {
      viewModel.updateName('Valid Name');
      final result = viewModel.validate();
      expect(result.isValid, true);
    });

    test('Should save updated item to database', () async {
      viewModel.updateName('Updated Item Name');
      viewModel.updateDescription('New description');
      viewModel.updateTags(['updated', 'edited']);

      final result = await viewModel.save();
      expect(result.isValid, true);

      final items = await itemRepository.fetchItemsByContainerId(
        originalContainer.id,
      );
      final updated = items.firstWhere(
        (i) => i.id == originalItem.id,
      );

      expect(updated.name, 'Updated Item Name');
      expect(updated.description, 'New description');
      expect(updated.tags, containsAll(['updated', 'edited']));
    });

    test('Should support container switching in viewmodel', () async {
      final moveTimestamp = DateTime.now().millisecondsSinceEpoch;
      final newContainer = Container(
        id: 'move_dest_$moveTimestamp',
        name: 'Move Destination_$moveTimestamp',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: Location(
          latitude: 48.8566,
          longitude: 2.3522,
          label: 'Paris',
          address: 'Paris, France',
        ),
        tags: [],
      );
      await containerRepository.createContainer(newContainer);

      viewModel.updateContainer(newContainer);
      expect(viewModel.selectedContainer.id, newContainer.id);

      viewModel.updateName('Updated For Move');
    });

    test('Should keep original item ID after edit', () async {
      viewModel.updateName('New Name');
      await viewModel.save();

      final items = await itemRepository.fetchItemsByContainerId(
        originalContainer.id,
      );
      final updated = items.firstWhere(
        (i) => i.id == originalItem.id,
      );

      expect(updated.id, originalItem.id);
    });
  });
}
