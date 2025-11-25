import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/repositories/container_repository.dart';

class ContainersScreenViewModel extends ChangeNotifier {
  final ContainerRepository _repository;

  List<models.Container> _containers = [];
  List<models.Container> _searchResults = [];
  String _query = "";
  bool _isLoading = false;
  String? _error;
  bool _isSearching = false;

  List<models.Container> get containers {
    if (_query.isEmpty) {
      return _containers;
    }
    return _searchResults;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSearching => _isSearching;
  String get query => _query;

  ContainersScreenViewModel(this._repository) {
    loadContainers();
  }

  Future<void> loadContainers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _containers = await _repository.fetchContainers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateQuery(String newQuery) async {
    _query = newQuery;
    notifyListeners();

    if (newQuery.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await _repository.searchContainers(_query);
    } catch (e) {
      print(e);
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }
}
