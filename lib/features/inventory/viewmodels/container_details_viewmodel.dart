import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/item.dart' as models;
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';

enum SortBy { name, dateAdded }

enum SortOrder { ascending, descending }

class ContainerDetailsViewModel extends ChangeNotifier {
  final ContainerRepository _containerRepository;
  final ItemRepository _itemRepository;
  
  models.Container? _container;
  models.Container? get container => _container;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  SortBy _sortBy = SortBy.dateAdded;
  SortBy get sortBy => _sortBy;

  SortOrder _sortOrder = SortOrder.descending;
  SortOrder get sortOrder => _sortOrder;

  ContainerDetailsViewModel(
    this._containerRepository,
    this._itemRepository,
  ) {
    _containerRepository.onDataChanged.listen((_) {
      if (_container != null) {
        loadContainer(_container!.id);
      }
    });
    _itemRepository.onDataChanged.listen((_) {
      if (_container != null) {
        loadContainer(_container!.id);
      }
    });
  }
  
  void initialize(String containerId) {
    loadContainer(containerId);
  }

  List<models.Item> get sortedItems {
    if (_container == null) return [];

    final items = List<models.Item>.from(_container!.items);

    items.sort((a, b) {
      int comparison;

      switch (_sortBy) {
        case SortBy.name:
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case SortBy.dateAdded:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }

      return _sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    return items;
  }

  Future<void> loadContainer(String containerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final container = await _containerRepository.fetchContainerById(
        containerId,
      );
      final items = await _itemRepository.fetchItemsByContainerId(containerId);
      _container = container.copyWith(items: items);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteContainer(
    String containerId,
    ContainerRepository repository,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.deleteContainer(containerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSortOptions(SortBy sortBy, SortOrder sortOrder) {
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    notifyListeners();
  }
}
