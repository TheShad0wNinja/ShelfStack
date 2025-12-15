import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelfstack/core/models/form_validation_response.dart';
import 'package:shelfstack/core/utils/files_helper.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/location.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/features/map/util/address_helper.dart';

class CreateContainerViewModel extends ChangeNotifier {
  final ContainerRepository _containerRepository;

  String _name = '';
  String _locationLabel = '';
  String? _locationAddress;
  LatLng? _selectedLocation;
  String? _photoUrl;
  List<String> _tags = [];
  bool _isLoading = false;
  String? _error;

  CreateContainerViewModel(this._containerRepository) {
    _containerRepository.onDataChanged.listen((_) {});
  }

  String get name => _name;
  String get locationLabel => _locationLabel;
  String? get locationAddress => _locationAddress;
  LatLng? get selectedLocation => _selectedLocation;
  String? get photoUrl => _photoUrl;
  List<String> get tags => _tags;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool _addressLoading = false;
  bool get addressLoading => _addressLoading;

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

  void updateLocation(LatLng location) async {
    _addressLoading = true;
    notifyListeners();
    final address = await fetchAddressFromLatLng(location);
    _selectedLocation = location;
    _locationAddress = address;
    _addressLoading = false;
    notifyListeners();
  }

  FormValidationResponse validate() {
    if (_name.trim().isEmpty) {
      return FormValidationResponse.fieldErrors({'name': 'Container name cannot be empty'});
    }
    return FormValidationResponse.success();
  }

  Future<FormValidationResponse> createContainer() async {
    final validationResult = validate();
    if (!validationResult.isValid) {
      return validationResult;
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
          latitude: _selectedLocation?.latitude ?? 0.0,
          longitude: _selectedLocation?.longitude ?? 0.0,
        ),
        tags: _tags,
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _containerRepository.createContainer(newContainer);

      _isLoading = false;
      notifyListeners();
      return FormValidationResponse.success();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return FormValidationResponse.generalError('Failed to create container: $e');
    }
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
