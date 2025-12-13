import 'package:flutter/material.dart';
import 'package:shelfstack/core/utils/files_helper.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/location.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';

class CreateContainerViewModel extends ChangeNotifier {
  String _name = '';
  String _locationLabel = '';
  String? _locationAddress;
  String? _photoUrl;
  List<String> _tags = [];
  bool _isLoading = false;
  String? _error;

  String get name => _name;
  String get locationLabel => _locationLabel;
  String? get locationAddress => _locationAddress;
  String? get photoUrl => _photoUrl;
  List<String> get tags => _tags;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  void updateLocationLabel(String value) {
    _locationLabel = value;
    notifyListeners();
  }

  void updatePhotoUrl(String? value) {
    _photoUrl = value;
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

  void useCurrentLocation() {
    _locationAddress = '123 Street, Storage room';
    notifyListeners();
  }

  Future<bool> createContainer(ContainerRepository repository) async {
    if (_name.trim().isEmpty) {
      _error = 'Container name cannot be empty';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newContainer = models.Container(
        id: "",
        name: _name,
        photoUrl: _photoUrl,
        location: Location(
          label: _locationLabel.isEmpty ? 'Unassigned' : _locationLabel,
          address: _locationAddress ?? '',
          latitude: 0,
          longitude: 0,
        ),
        tags: _tags,
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createContainer(newContainer);

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
      // _error = "Error picking image";
      notifyListeners();
      return;
    }
    final filePath = await saveImageFile(imagePath);
    _photoUrl = filePath;
    notifyListeners();
  }
}
