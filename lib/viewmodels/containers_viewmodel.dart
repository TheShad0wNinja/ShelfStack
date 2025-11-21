import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/container_repository_fake.dart';

class ContainersViewModel extends ChangeNotifier {
  final ContainerRepository _repository = ContainerRepositoryFake();

  List<models.Container> _containers = [];
  bool _isLoading = false;
  String? _error;

  List<models.Container> get containers => _containers;

  bool get isLoading => _isLoading;

  String? get error => _error;

  int get totalContainers => _containers.length;

  int get totalItems =>
      _containers.fold(0, (sum, container) => sum + container.items.length);

  ContainersViewModel() {
    loadContainers();
  }

  Future<void> loadContainers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _containers = await _repository.fetchContainers();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _containers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<models.Container?> getContainerById(String id) async {
    try {
      return await _repository.fetchContainerById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<List<models.Container>> searchContainers(String query) async {
    try {
      return await _repository.searchContainers(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<List<Item>> searchItems(String query) async {
    try {
      return await _repository.searchItems(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<bool> createContainer(models.Container container) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.createContainer(container);
      await loadContainers(); // Reload to get updated list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateContainer(models.Container container) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateContainer(container);
      await loadContainers(); // Reload to get updated list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteContainer(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteContainer(id);
      await loadContainers(); // Reload to get updated list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refresh() {
    loadContainers();
  }

  // Helper method to get container name by ID
  String? getContainerNameById(String containerId) {
    try {
      return _containers.firstWhere((c) => c.id == containerId).name;
    } catch (e) {
      return null;
    }
  }

  // Helper method to get container location by ID
  String? getContainerLocationById(String containerId) {
    try {
      return _containers.firstWhere((c) => c.id == containerId).location.label;
    } catch (e) {
      return null;
    }
  }
}
