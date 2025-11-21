import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/features/inventory/viewmodels/containers_viewmodel.dart';

class ContainerDetailsViewModel extends ChangeNotifier {
  models.Container? _container;
  bool _isLoading = false;
  String? _error;

  models.Container? get container => _container;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadContainer(
    String containerId,
    ContainersViewModel containersVm,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _container = await containersVm.getContainerById(containerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
