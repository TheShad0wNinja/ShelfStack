import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';

class EditItemViewModel extends ChangeNotifier {
  final ItemRepository _itemRepository;
  final ContainerRepository _containerRepository;

  EditItemViewModel(this._itemRepository, this._containerRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<models.Container> _availableContainers = [];
  List<models.Container> get availableContainers => _availableContainers;

  List<models.Container> _filteredContainers = [];
  List<models.Container> get filteredContainers => _filteredContainers;

  String _containerSearchQuery = '';
  String get containerSearchQuery => _containerSearchQuery;

  Future<void> loadAvailableContainers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availableContainers = await _containerRepository.fetchContainers();
      _filteredContainers = _availableContainers;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchContainers(String query) {
    _containerSearchQuery = query;

    if (query.isEmpty) {
      _filteredContainers = _availableContainers;
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredContainers = _availableContainers.where((container) {
        return container.name.toLowerCase().contains(lowerQuery) ||
            container.location.label.toLowerCase().contains(lowerQuery) ||
            container.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }).toList();
    }

    notifyListeners();
  }

  Future<bool> updateItem({
    required String itemId,
    required String name,
    String? description,
    String? photoUrl,
    required List<String> tags,
    required String containerId,
    required Item originalItem
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (containerId != originalItem.containerId) {
        final success = await _moveItem(itemId: itemId,
            fromContainerId: originalItem.containerId,
            toContainerId: containerId);

        if (!success) {
          notifyListeners();
          return false;
        }
      }

      final updatedItem = Item(
        id: itemId,
        name: name,
        description: description,
        photoUrl: photoUrl,
        tags: tags,
        containerId: containerId,
        externalDocumentUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _itemRepository.updateItem(updatedItem);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _moveItem({
    required String itemId,
    required String fromContainerId,
    required String toContainerId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _itemRepository.moveItemToContainer(
        itemId,
        fromContainerId,
        toContainerId,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
