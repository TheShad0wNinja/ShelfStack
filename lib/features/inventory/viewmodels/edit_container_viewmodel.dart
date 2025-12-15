import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelfstack/core/models/form_validation_response.dart';
import 'package:shelfstack/core/utils/files_helper.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/location.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/features/map/util/address_helper.dart';

class EditContainerViewModel extends ChangeNotifier {
  final ContainerRepository _repository;
  final models.Container _container;

  String _name = "";
  Location? _location;
  List<String> _tags = [];
  String? _photoUrl;

  String? get photoUrl => _photoUrl;
  Location? get location => _location;

  bool _addressLoading = false;
  bool get addressLoading => _addressLoading;


  EditContainerViewModel(this._container, this._repository) {
    _name = _container.name;
    _location = _container.location;
    _tags = List.from(_container.tags);
    _photoUrl = _container.photoUrl;
    _repository.onDataChanged.listen((_) {});
  }

  void updateName(String s) {
    _name = s;
    notifyListeners();
  }

  void updateLocation(LatLng location) async {
    _addressLoading = true;
    notifyListeners();
    final address = await fetchAddressFromLatLng(location);
    _location = Location(
      label: _location?.label ?? 'Unassigned',
      latitude: location.latitude,
      longitude: location.longitude,
      address: address,
    );
    _addressLoading = false;
    notifyListeners();
  }

  void updateLocationLabel(String s) {
    _location ??= Location(label: s, longitude: 0, latitude: 0, address: "");
    _location = _location!.copyWith(label: s);
    notifyListeners();
  }

  void updateTags(List<String> tags) {
    _tags = tags;
    notifyListeners();
  }

  void updatePhotoUrl(String? url) {
    _photoUrl = url;
    notifyListeners();
  }

  Future<FormValidationResponse> save() async {
    if (_name.trim().isEmpty) {
      return FormValidationResponse.generalError("Container name cannot be empty");
    }
    try {
      models.Container newContainer = _container.copyWith(
        location: _location,
        name: _name,
        tags: _tags,
        photoUrl: _photoUrl,
      );
      await _repository.updateContainer(newContainer);
      return FormValidationResponse.success();
    } catch (e) {
      return FormValidationResponse.generalError(e.toString());
    }
  }

  void choosePhoto() async {
    final imagePath = await pickImage();
    if (imagePath == null) {
      // _error = "Error picking image";
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
