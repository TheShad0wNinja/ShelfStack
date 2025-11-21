import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/features/inventory/viewmodels/containers_viewmodel.dart';

enum SearchFilter { all, containersOnly, itemsOnly }

class SearchViewModel extends ChangeNotifier {
  String _query = '';
  SearchFilter _selectedFilter = SearchFilter.all;
  List<models.Container> _containerResults = [];
  List<Item> _itemResults = [];
  bool _isSearching = false;

  String get query => _query;
  SearchFilter get selectedFilter => _selectedFilter;
  List<models.Container> get containerResults => _containerResults;
  List<Item> get itemResults => _itemResults;
  bool get isSearching => _isSearching;
  int get totalResults => _containerResults.length + _itemResults.length;

  void updateQuery(String newQuery, ContainersViewModel containersVm) {
    _query = newQuery;
    _performSearch(containersVm);
  }

  void updateFilter(SearchFilter newFilter, ContainersViewModel containersVm) {
    _selectedFilter = newFilter;
    _performSearch(containersVm);
  }

  Future<void> _performSearch(ContainersViewModel containersVm) async {
    if (_query.isEmpty) {
      _containerResults = [];
      _itemResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    if (_selectedFilter == SearchFilter.all ||
        _selectedFilter == SearchFilter.containersOnly) {
      _containerResults = await containersVm.searchContainers(_query);
    } else {
      _containerResults = [];
    }

    if (_selectedFilter == SearchFilter.all ||
        _selectedFilter == SearchFilter.itemsOnly) {
      _itemResults = await containersVm.searchItems(_query);
    } else {
      _itemResults = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    _containerResults = [];
    _itemResults = [];
    _isSearching = false;
    notifyListeners();
  }
}
