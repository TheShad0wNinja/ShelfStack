import 'package:flutter_test/flutter_test.dart';
import 'package:shelfstack/data/models/container.dart';
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/models/location.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';
import 'package:shelfstack/features/home/home_viewmodel.dart';

class FakeContainerRepository implements ContainerRepository {
  int? _totalContainerCount;
  List<Container>? _recentContainers;

  void setTotalContainerCount(int count) => _totalContainerCount = count;
  void setRecentContainers(List<Container> containers) => _recentContainers = containers;

  @override
  Stream<void> get onDataChanged => Stream.empty();

  @override
  Future<List<Container>> fetchContainers() async => [];

  @override
  Future<Container> fetchContainerById(String id) async =>
      throw UnimplementedError();

  @override
  Future createContainer(Container container) async {}

  @override
  Future updateContainer(Container container) async {}

  @override
  Future deleteContainer(String id) async {}

  @override
  Future<List<Container>> searchContainers(String query) async => [];

  @override
  Future<int> fetchTotalContainerCount() async => _totalContainerCount ?? 0;

  @override
  Future<List<Container>> fetchRecentContainers(int amount) async =>
      _recentContainers ?? [];
}

class FakeItemRepository implements ItemRepository {
  int? _totalItemCount;

  void setTotalItemCount(int count) => _totalItemCount = count;

  @override
  Stream<void> get onDataChanged => Stream.empty();

  @override
  Future<List<Item>> fetchItemsByContainerId(String containerId) async => [];

  @override
  Future<Item> fetchItemById(String id) async => throw UnimplementedError();

  @override
  Future createItem(Item item) async {}

  @override
  Future updateItem(Item item) async {}

  @override
  Future deleteItem(String id) async {}

  @override
  Future<List<Item>> searchItems(String query) async => [];

  @override
  Future<int> fetchTotalItemCount() async => _totalItemCount ?? 0;

  @override
  Future assignItemToContainer(String itemId, String containerId) async {}

  @override
  Future moveItemToContainer(
    String itemId,
    String fromContainerId,
    String toContainerId,
  ) async {}
}

void main() {
  group('HomeViewModel Tests', () {
    late FakeContainerRepository fakeContainerRepository;
    late FakeItemRepository fakeItemRepository;
    late HomeViewModel homeViewModel;

    setUp(() {
      fakeContainerRepository = FakeContainerRepository();
      fakeItemRepository = FakeItemRepository();
    });

    test('Initial state should show loading', () {
      fakeContainerRepository.setTotalContainerCount(5);
      fakeItemRepository.setTotalItemCount(12);
      fakeContainerRepository.setRecentContainers([]);

      homeViewModel = HomeViewModel(
        fakeContainerRepository,
        fakeItemRepository,
      );

      expect(homeViewModel.isLoadingInfo, isTrue);
      expect(homeViewModel.isLoadingContainers, isTrue);
    });

    test('loadData should fetch total containers and items count', () async {
      fakeContainerRepository.setTotalContainerCount(5);
      fakeItemRepository.setTotalItemCount(12);
      fakeContainerRepository.setRecentContainers([]);

      homeViewModel = HomeViewModel(
        fakeContainerRepository,
        fakeItemRepository,
      );

      await Future.delayed(const Duration(milliseconds: 200));

      expect(homeViewModel.totalContainers, 5);
      expect(homeViewModel.totalItems, 12);
    });

    test('loadData should fetch recent containers', () async {
      final location = Location(
        latitude: 30.0,
        longitude: 31.0,
        label: 'Kitchen',
        address: '123 Main St',
      );

      final mockContainer = Container(
        id: '1',
        name: 'Kitchen',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: location,
        tags: ['kitchen'],
      );

      fakeContainerRepository.setTotalContainerCount(5);
      fakeItemRepository.setTotalItemCount(12);
      fakeContainerRepository.setRecentContainers([mockContainer]);

      homeViewModel = HomeViewModel(
        fakeContainerRepository,
        fakeItemRepository,
      );

      await Future.delayed(const Duration(milliseconds: 200));

      expect(homeViewModel.recentContainers.length, 1);
      expect(homeViewModel.recentContainers[0].name, 'Kitchen');
      expect(homeViewModel.recentContainers[0].id, '1');
    });

    test('loadData should fetch container count', () async {
      fakeContainerRepository.setTotalContainerCount(10);
      fakeItemRepository.setTotalItemCount(50);
      fakeContainerRepository.setRecentContainers([]);

      homeViewModel = HomeViewModel(
        fakeContainerRepository,
        fakeItemRepository,
      );

      await Future.delayed(const Duration(milliseconds: 200));

      expect(homeViewModel.totalContainers, 10);
      expect(homeViewModel.totalItems, 50);
    });

    test('loadData should handle zero containers and items', () async {
      fakeContainerRepository.setTotalContainerCount(0);
      fakeItemRepository.setTotalItemCount(0);
      fakeContainerRepository.setRecentContainers([]);

      homeViewModel = HomeViewModel(
        fakeContainerRepository,
        fakeItemRepository,
      );

      await Future.delayed(const Duration(milliseconds: 200));

      expect(homeViewModel.totalContainers, 0);
      expect(homeViewModel.totalItems, 0);
      expect(homeViewModel.recentContainers, isEmpty);
    });

    test('Multiple recent containers should all be returned', () async {
      final location = Location(
        latitude: 30.0,
        longitude: 31.0,
        label: 'Location',
        address: '123 Main St',
      );

      final containers = [
        Container(
          id: '1',
          name: 'Container 1',
          photoUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          items: [],
          location: location,
          tags: [],
        ),
        Container(
          id: '2',
          name: 'Container 2',
          photoUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          items: [],
          location: location,
          tags: [],
        ),
        Container(
          id: '3',
          name: 'Container 3',
          photoUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          items: [],
          location: location,
          tags: [],
        ),
      ];

      fakeContainerRepository.setTotalContainerCount(10);
      fakeItemRepository.setTotalItemCount(50);
      fakeContainerRepository.setRecentContainers(containers);

      homeViewModel = HomeViewModel(
        fakeContainerRepository,
        fakeItemRepository,
      );

      await Future.delayed(const Duration(milliseconds: 200));

      expect(homeViewModel.recentContainers.length, 3);
      expect(homeViewModel.recentContainers[0].id, '1');
      expect(homeViewModel.recentContainers[1].id, '2');
      expect(homeViewModel.recentContainers[2].id, '3');
    });
  });
}
