import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/repositories/container_repository.dart';

class ContainerDetailsViewModel extends ChangeNotifier {
  models.Container? _container;
  bool _isLoading = false;
  String? _error;

  models.Container? get container => _container;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadContainer(
    String containerId,
    ContainerRepository repository,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _container = await repository.fetchContainerById(containerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
