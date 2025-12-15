import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shelfstack/core/models/form_validation_response.dart';
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
    
    _itemRepository.onDataChanged.listen((_) {
      _loadAvailableContainers();
    });
    _containerRepository.onDataChanged.listen((_) {
      _loadAvailableContainers();
    });
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Item get item => _originalItem;

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
      if (kDebugMode) {
        print('Error loading containers: $e');
      }
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

  FormValidationResponse validate() {
    final errors = <String, String>{};
    
    if (_name.trim().isEmpty) {
      errors['name'] = 'Item name is required';
    }

    if (errors.isNotEmpty) {
      return FormValidationResponse.fieldErrors(errors);
    }

    return FormValidationResponse.success();
  }

  Future<FormValidationResponse> save() async {
    final validationResult = validate();
    if (!validationResult.isValid) {
      return validationResult;
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (_selectedContainer.id != _originalItem.containerId) {
        final moveResult = await _moveItem(
          itemId: _originalItem.id,
          fromContainerId: _originalItem.containerId,
          toContainerId: _selectedContainer.id,
        );

        if (!moveResult.isValid) {
          return moveResult;
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
      return FormValidationResponse.success();
    } catch (e) {
      return FormValidationResponse.generalError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<FormValidationResponse> _moveItem({
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
      return FormValidationResponse.success();
    } catch (e) {
      return FormValidationResponse.generalError(e.toString());
    }
  }

  void updatePhotoUrl(String? url) {
    _photoUrl = url;
    notifyListeners();
  }

  Future<FormValidationResponse> choosePhoto() async {
    try {
      final imagePath = await pickImage();
      if (imagePath == null) {
        return FormValidationResponse.generalError("Image selection cancelled");
      }
      final filePath = await saveImageFile(imagePath);
      _photoUrl = filePath;
      notifyListeners();
      return FormValidationResponse.success();
    } catch (e) {
      return FormValidationResponse.generalError("Error picking image: $e");
    }
  }

  Future<FormValidationResponse> takePhoto() async {
    try {
      final imagePath = await takeImagePhoto();
      if (imagePath == null) {
        return FormValidationResponse.generalError("Photo capture cancelled");
      }
      final filePath = await saveImageFile(imagePath);
      _photoUrl = filePath;
      notifyListeners();
      return FormValidationResponse.success();
    } catch (e) {
      return FormValidationResponse.generalError("Error taking photo: $e");
    }
  }
}
