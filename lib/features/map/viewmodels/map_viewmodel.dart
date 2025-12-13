import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/repositories/container_repository.dart';

class MapViewModel extends ChangeNotifier {
  final ContainerRepository _containerRepository;

  MapViewModel(this._containerRepository) {
    init();
  }

  List<models.Container> _containers = [];

  List<models.Container> get containers => _containers;

  LatLng? _userLocation;

  LatLng? get userLocation => _userLocation;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _error;

  String? get error => _error;

  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.wait([fetchContainers(), getCurrentLocation()]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchContainers() async {
    try {
      _containers = await _containerRepository.fetchContainers();
      notifyListeners();
    } catch (e) {
      _containers = [];
      _error = 'Failed to fetch containers: $e';
      notifyListeners();
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      final bool locationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!locationEnabled) {
        _error = 'Location services are disabled';
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Location permissions are denied';
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error = 'Location permissions are permanently denied, we cannot request permissions.';
        notifyListeners();
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      _userLocation = LatLng(position.latitude, position.longitude);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to get current location: $e';
      notifyListeners();
    }
  }
}
