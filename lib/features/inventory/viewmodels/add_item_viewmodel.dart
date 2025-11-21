import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/features/inventory/viewmodels/containers_viewmodel.dart';

class AddItemViewModel extends ChangeNotifier {
  String _name = '';
  String _description = '';
  List<String> _tags = [];
  String? _photoUrl;
  bool _isLoading = false;
  String? _error;

  String get name => _name;
  String get description => _description;
  List<String> get tags => _tags;
  String? get photoUrl => _photoUrl;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  Future<bool> saveItem(
    String containerId,
    ContainersViewModel containersVm,
  ) async {
    if (_name.isEmpty) {
      _error = 'Name is required';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final container = await containersVm.getContainerById(containerId);
      if (container == null) {
        throw Exception('Container not found');
      }

      final newItem = Item(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _name,
        description: _description,
        containerId: containerId,
        tags: _tags,
        photoUrl: _photoUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedContainer = container.copyWith(
        items: [...container.items, newItem],
        updatedAt: DateTime.now(),
      );

      await containersVm.updateContainer(updatedContainer);

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
