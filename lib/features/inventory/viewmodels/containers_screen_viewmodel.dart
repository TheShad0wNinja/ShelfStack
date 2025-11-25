import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/features/inventory/viewmodels/containers_viewmodel.dart';

class ContainersScreenViewModel extends ChangeNotifier {
  String _query = "";
  List<models.Container> _searchResults = [];

  String get query => _query;
  List<models.Container> get containers {
    if (_query.isEmpty) {
      return _containersVm.containers;
    }
    return _searchResults;
  }

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  ContainersViewModel _containersVm;

  ContainersScreenViewModel(this._containersVm);

  void updateContainersVM(ContainersViewModel vm) {
    _containersVm = vm;
    notifyListeners();
  }

  void updateQuery(String newQuery) async {
    _query = newQuery;
    notifyListeners();
    if (newQuery.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    };

    _isSearching = true;

    try {
      _searchResults = await _containersVm.searchContainers(_query);
    } catch(e) {
      print(e);
      _searchResults = [];
    } finally {
      _isSearching = false;
    }

    notifyListeners();
  }
}