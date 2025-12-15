import 'package:flutter/material.dart' hide Container;
import 'package:shelfstack/core/models/form_validation_response.dart';
import 'package:shelfstack/data/models/container.dart';
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';

class ItemDetailsViewModel extends ChangeNotifier {
  final ItemRepository _itemRepository;
  final ContainerRepository _containerRepository;
  final String _itemId;


  Item? _item;
  Item? get item => _item;

  Container? _container;
  Container? get container => _container;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  ItemDetailsViewModel(
    this._itemId,
    this._containerRepository,
    this._itemRepository,
  ) {
    _itemRepository.onDataChanged.listen((_) {
      loadItem();
    });
    _containerRepository.onDataChanged.listen((_) {
      loadItem();
    });
    loadItem();
  }

  Future<void> loadItem() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _item = await _itemRepository.fetchItemById(_itemId);
      if (_item != null) {
        _container = await _containerRepository.fetchContainerById(_item!.containerId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateData(Item item, Container container) {
    _item = item;
    _container = container;
    notifyListeners();
  }

  Future<FormValidationResponse> deleteItem() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _itemRepository.deleteItem(_itemId);
      _isLoading = false;
      notifyListeners();
      return FormValidationResponse.success();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return FormValidationResponse.generalError('Failed to delete item: $e');
    }
  }
}
