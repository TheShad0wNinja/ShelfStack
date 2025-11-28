import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';

class AddItemViewModel extends ChangeNotifier {
  String _name = '';
  String _description = '';
  String? _photoUrl;
  List<String> _tags = [];
  bool _isLoading = false;
  String? _error;
  models.Container? _selectedContainer;

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

  Future<void> loadContainer(
    String containerId,
    ContainerRepository repository,
  ) async {
    try {
      final container = await repository.fetchContainerById(containerId);
      _selectedContainer = container;
      notifyListeners();
    } catch (e) {
      // Handle error silently or log it, as this is just initial loading
    }
  }

  Future<bool> save(ItemRepository itemRepository) async {
    if (_name.trim().isEmpty) {
      _error = 'Name cannot be empty';
      notifyListeners();
      return false;
    }

    if (_selectedContainer == null) {
      _error = 'Please select a container';
      notifyListeners();
      return false;
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

      await itemRepository.createItem(newItem);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
