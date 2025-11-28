import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/location.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';

class ContainerEditViewModel extends ChangeNotifier {
  final ContainerRepository _repository;
  models.Container _container;

  String _name = "";
  Location? _location;
  List<String> _tags = [];
  String? _photoUrl;

  ContainerEditViewModel(this._container, this._repository) {
    _name = _container.name;
    _location = _container.location;
    _tags = List.from(_container.tags);
    _photoUrl = _container.photoUrl;
  }

  void updateName(String s) {
    _name = s;
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

  Future<void> save(BuildContext context) async {
    if (_name.trim().isEmpty) {
      throw Exception("Container name cannot be empty");
    }
    models.Container newContainer = _container.copyWith(
      location: _location,
      name: _name,
      tags: _tags,
      photoUrl: _photoUrl,
    );
    await _repository.updateContainer(newContainer);
  }
}
