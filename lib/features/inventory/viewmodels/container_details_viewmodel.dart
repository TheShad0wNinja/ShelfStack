import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/item.dart' as models;
import 'package:shelfstack/data/repositories/container_repository.dart';

enum SortBy { name, dateAdded }
enum SortOrder { ascending, descending }

class ContainerDetailsViewModel extends ChangeNotifier {
  models.Container? _container;
  models.Container? get container => _container;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  SortBy _sortBy = SortBy.dateAdded;
  SortBy get sortBy => _sortBy;

  SortOrder _sortOrder = SortOrder.descending;
  SortOrder get sortOrder => _sortOrder;


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

  Future<void> loadContainer(
      String containerId,
      ContainerRepository repository,
      ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _container = await repository.fetchContainerById(containerId);
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