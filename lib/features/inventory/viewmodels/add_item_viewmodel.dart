import 'package:flutter/material.dart';
import 'package:shelfstack/core/models/form_validation_response.dart';
import 'package:shelfstack/core/utils/files_helper.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';

class AddItemViewModel extends ChangeNotifier {
  final ItemRepository _itemRepository;
  final ContainerRepository _containerRepository;
  
  String _name = '';
  String _description = '';
  String? _photoUrl;
  List<String> _tags = [];
  bool _isLoading = false;
  String? _error;
  models.Container? _selectedContainer;
  
  AddItemViewModel(
    this._itemRepository,
    this._containerRepository,
  ) {
    _itemRepository.onDataChanged.listen((_) => {});
    _containerRepository.onDataChanged.listen((_) => {});
  }

  String get name => _name;
  String get description => _description;
  String? get photoUrl => _photoUrl;
  List<String> get tags => _tags;
  bool get isLoading => _isLoading;
  String? get error => _error;
  models.Container? get selectedContainer => _selectedContainer;

  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  void updateDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      _tags.add(tag);
      notifyListeners();
    }
  }

  void removeTag(String tag) {
    _tags.remove(tag);
    notifyListeners();
  }

  void updatePhotoUrl(String? url) {
    _photoUrl = url;
    notifyListeners();
  }

  void setContainer(models.Container? container) {
    _selectedContainer = container;
    notifyListeners();
  }

  Future<void> loadContainer(String containerId) async {
    try {
      final container = await _containerRepository.fetchContainerById(containerId);
      _selectedContainer = container;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  FormValidationResponse validate() {
    final errors = <String, String>{};

    if (_name.trim().isEmpty) {
      errors['name'] = 'Name cannot be empty';
    }

    if (_selectedContainer == null) {
      errors['container'] = 'Please select a container';
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
    _error = null;
    notifyListeners();

    try {
      final newItem = Item(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _name.trim(),
        description: _description.trim().isEmpty ? null : _description.trim(),
        photoUrl: _photoUrl,
        tags: _tags,
        containerId: _selectedContainer!.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _itemRepository.createItem(newItem);

      _isLoading = false;
      notifyListeners();
      return FormValidationResponse.success();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return FormValidationResponse.generalError('Failed to add item: $e');
    }
  }

  void choosePhoto() async {
    final imagePath = await pickImage();
    if (imagePath == null) {
      _error = "Error picking image";
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
