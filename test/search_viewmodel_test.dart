import 'package:flutter_test/flutter_test.dart';
import 'package:shelfstack/data/models/container.dart';
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/models/location.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';
import 'package:shelfstack/features/search/search_viewmodel.dart';

class FakeContainerRepository implements ContainerRepository {
  List<Container>? mockSearchResults;

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
  Future<List<Container>> searchContainers(String query) async =>
      mockSearchResults ?? [];

  @override
  Future<int> fetchTotalContainerCount() async => 0;

  @override
  Future<List<Container>> fetchRecentContainers(int amount) async => [];
}

class FakeItemRepository implements ItemRepository {
  List<Item>? mockSearchResults;

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
  Future<List<Item>> searchItems(String query) async => mockSearchResults ?? [];

  @override
  Future<int> fetchTotalItemCount() async => 0;

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
  group('SearchViewModel Tests', () {
    late FakeContainerRepository fakeContainerRepository;
    late FakeItemRepository fakeItemRepository;
    late SearchViewModel searchViewModel;

    setUp(() {
      fakeContainerRepository = FakeContainerRepository();
      fakeItemRepository = FakeItemRepository();

      searchViewModel = SearchViewModel(
        fakeContainerRepository,
        fakeItemRepository,
      );
    });

    test('Initial state should have empty query and no results', () {
      expect(searchViewModel.query, isEmpty);
      expect(searchViewModel.containerResults, isEmpty);
      expect(searchViewModel.itemResults, isEmpty);
      expect(searchViewModel.totalResults, 0);
      expect(searchViewModel.selectedFilter, SearchFilter.all);
    });

    test('updateQuery should update the query', () async {
      final mockContainer = Container(
        id: '1',
        name: 'Kitchen',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: Location(
          latitude: 30.0,
          longitude: 31.0,
          label: 'Kitchen',
          address: '123 Main St',
        ),
        tags: ['kitchen'],
      );

      fakeContainerRepository.mockSearchResults = [mockContainer];
      fakeItemRepository.mockSearchResults = [];

      searchViewModel.updateQuery('kit');
      await Future.delayed(const Duration(milliseconds: 100));

      expect(searchViewModel.query, 'kit');
    });

    test('updateFilter should change the search filter', () async {
      fakeContainerRepository.mockSearchResults = [];
      fakeItemRepository.mockSearchResults = [];

      searchViewModel.updateFilter(SearchFilter.itemsOnly);

      expect(searchViewModel.selectedFilter, SearchFilter.itemsOnly);
    });

    test('clearSearch should reset query and results', () async {
      final mockContainer = Container(
        id: '1',
        name: 'Kitchen',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: Location(
          latitude: 30.0,
          longitude: 31.0,
          label: 'Kitchen',
          address: '123 Main St',
        ),
        tags: ['kitchen'],
      );

      fakeContainerRepository.mockSearchResults = [mockContainer];
      fakeItemRepository.mockSearchResults = [];

      searchViewModel.updateQuery('kit');
      await Future.delayed(const Duration(milliseconds: 100));

      searchViewModel.clearSearch();

      expect(searchViewModel.query, isEmpty);
      expect(searchViewModel.containerResults, isEmpty);
      expect(searchViewModel.itemResults, isEmpty);
    });

    test('Search with containersOnly filter should search only containers', () async {
      final mockContainer = Container(
        id: '1',
        name: 'Kitchen',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: Location(
          latitude: 30.0,
          longitude: 31.0,
          label: 'Kitchen',
          address: '123 Main St',
        ),
        tags: ['kitchen'],
      );

      fakeContainerRepository.mockSearchResults = [mockContainer];
      fakeItemRepository.mockSearchResults = [];

      searchViewModel.updateFilter(SearchFilter.containersOnly);
      searchViewModel.updateQuery('kit');
      await Future.delayed(const Duration(milliseconds: 100));

      expect(searchViewModel.containerResults, isNotEmpty);
      expect(searchViewModel.selectedFilter, SearchFilter.containersOnly);
    });

    test('totalResults should return sum of container and item results', () async {
      final mockContainer = Container(
        id: '1',
        name: 'Kitchen',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: [],
        location: Location(
          latitude: 30.0,
          longitude: 31.0,
          label: 'Kitchen',
          address: '123 Main St',
        ),
        tags: ['kitchen'],
      );

      final mockItem = Item(
        id: '1',
        name: 'Knife',
        description: null,
        photoUrl: null,
        tags: ['kitchen'],
        containerId: '1',
        externalDocumentUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      fakeContainerRepository.mockSearchResults = [mockContainer];
      fakeItemRepository.mockSearchResults = [mockItem];

      searchViewModel.updateFilter(SearchFilter.all);
      searchViewModel.updateQuery('kit');
      await Future.delayed(const Duration(milliseconds: 100));

      expect(searchViewModel.totalResults, 2);
    });
  });
}
