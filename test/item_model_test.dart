import 'package:flutter_test/flutter_test.dart';
import 'package:shelfstack/data/database/database_helper.dart';
import 'package:shelfstack/data/models/container.dart';
import 'package:shelfstack/data/models/location.dart';
import 'package:shelfstack/data/database/container_repository_sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  setUpAll(() {
    // Initialize sqflite FFI for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Container Creation Integration Tests', () {
    late ContainerRepositorySqlite containerRepository;

    setUp(() async {
      // Initialize database
      containerRepository = ContainerRepositorySqlite();
      final dbHelper = DatabaseHelper();
      await dbHelper.database;
    });

    test('Should create a container and save it to SQLite database', () async {
      final location = Location(
        latitude: 30.044,
        longitude: 31.2357,
        label: 'Kitchen Cupboard',
        address: '123 Street, City',
      );

      final container = Container(
        id: 'test_container_1', // ID will be overwritten by createContainer
        name: 'Test Kitchen Supplies',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: location,
        tags: ['kitchen', 'storage'],
      );

      // Create container (note: the method generates a new UUID for the container)
      await containerRepository.createContainer(container);

      final allContainers = await containerRepository.fetchContainers();
      final savedContainer = allContainers.firstWhere(
        (c) => c.name == 'Test Kitchen Supplies',
        orElse: () => throw Exception('Container not found'),
      );
      
      expect(savedContainer.name, 'Test Kitchen Supplies');
      expect(savedContainer.location.label, 'Kitchen Cupboard');
      expect(savedContainer.tags, contains('kitchen'));
    });

    test('Should fetch total container count from database', () async {
      final location = Location(
        latitude: 30.0,
        longitude: 31.0,
        label: 'Test Location',
        address: 'Test Address',
      );

      final container = Container(
        id: 'test_container_count_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Count Test Container',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: location,
        tags: [],
      );

      final countBefore = await containerRepository.fetchTotalContainerCount();
      await containerRepository.createContainer(container);
      final countAfter = await containerRepository.fetchTotalContainerCount();

      expect(countAfter, greaterThan(countBefore));
    });

    test('Should delete a container from the database', () async {
      final location = Location(
        latitude: 30.0,
        longitude: 31.0,
        label: 'Delete Test',
        address: 'Delete Address',
      );

      final container = Container(
        id: 'temp_id',
        name: 'Container to Delete',
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
        (c) => c.name == 'Container to Delete',
        orElse: () => throw Exception('Container was not created'),
      );

      await containerRepository.deleteContainer(createdContainer.id);

      final remainingContainers = await containerRepository.fetchContainers();
      final stillExists = remainingContainers.any((c) => c.id == createdContainer.id);
      expect(stillExists, false);
    });
  });
}
