import 'package:flutter/material.dart';
import 'package:shelfstack/core/utils/files_helper.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';

class EditItemViewModel extends ChangeNotifier {
  final ItemRepository _itemRepository;
  final ContainerRepository _containerRepository;
  final Item _originalItem;
  final models.Container _originalContainer;

  EditItemViewModel(
    this._itemRepository,
    this._containerRepository,
    this._originalItem,
    this._originalContainer,
  ) {
    _name = _originalItem.name;
    _description = _originalItem.description;
    _tags = List.from(_originalItem.tags);
    _photoUrl = _originalItem.photoUrl;
    _selectedContainer = _originalContainer;
    _loadAvailableContainers();
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _error;

  String? get error => _error;

  late String _name;

  String get name => _name;

  String? _description;

  String? get description => _description;

  late List<String> _tags;

  List<String> get tags => _tags;

  String? _photoUrl;

  String? get photoUrl => _photoUrl;

  late models.Container _selectedContainer;

  models.Container get selectedContainer => _selectedContainer;

  List<models.Container> _availableContainers = [];

  List<models.Container> get availableContainers => _availableContainers;

  List<models.Container> _filteredContainers = [];

  List<models.Container> get filteredContainers => _filteredContainers;

  String _containerSearchQuery = '';

  String get containerSearchQuery => _containerSearchQuery;

  Future<void> _loadAvailableContainers() async {
    try {
      _availableContainers = await _containerRepository.fetchContainers();
      _filteredContainers = _availableContainers;
      notifyListeners();
    } catch (e) {
      print('Error loading containers: $e');
    }
  }

  void updateName(String name) {
    _name = name;
    notifyListeners();
  }

  void updateDescription(String? description) {
    _description = description;
    notifyListeners();
  }

  void updateTags(List<String> tags) {
    _tags = tags;
    notifyListeners();
  }

  void updateContainer(models.Container container) {
    _selectedContainer = container;
    notifyListeners();
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

  Future<bool> save() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_selectedContainer.id != _originalItem.containerId) {
        final success = await _moveItem(
          itemId: _originalItem.id,
          fromContainerId: _originalItem.containerId,
          toContainerId: _selectedContainer.id,
        );

        if (!success) {
          notifyListeners();
          return false;
        }
      }

      final updatedItem = Item(
        id: _originalItem.id,
        name: _name,
        description: _description?.isEmpty == true ? null : _description,
        photoUrl: _photoUrl,
        tags: _tags,
        containerId: _selectedContainer.id,
        externalDocumentUrl: null,
        createdAt: _originalItem.createdAt,
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
    }
  }

  void updatePhotoUrl(String? url) {
    _photoUrl = url;
    notifyListeners();
  }

  void choosePhoto() async {
    final imagePath = await pickImage();
    if (imagePath == null) {
      _error = "Error taking photo";
      notifyListeners();
      return;
    }
    final filePath = await saveImageFile(imagePath);
    _photoUrl = filePath;
    notifyListeners();
  }

  void takePhoto() async {
    final imagePath = await takeImagePhoto();
    if (imagePath == null) {
      _error = "Error picking image";
      notifyListeners();
      return;
    }
    final filePath = await saveImageFile(imagePath);
    _photoUrl = filePath;
    notifyListeners();
  }
}
