import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';

enum SearchFilter { all, containersOnly, itemsOnly }

class SearchViewModel extends ChangeNotifier {
  final ContainerRepository _containerRepository;
  final ItemRepository _itemRepository;

  String _query = '';
  SearchFilter _selectedFilter = SearchFilter.all;
  List<models.Container> _containerResults = [];
  List<Item> _itemResults = [];
  bool _isSearching = false;

  SearchViewModel(this._containerRepository, this._itemRepository) {
    _containerRepository.onDataChanged.listen((_) {
      if (_query.isNotEmpty) {
        _performSearch();
      }
    });
    _itemRepository.onDataChanged.listen((_) {
      if (_query.isNotEmpty) {
        _performSearch();
      }
    });
  }

  String get query => _query;
  SearchFilter get selectedFilter => _selectedFilter;
  List<models.Container> get containerResults => _containerResults;
  List<Item> get itemResults => _itemResults;
  bool get isSearching => _isSearching;
  int get totalResults => _containerResults.length + _itemResults.length;

  void updateQuery(String newQuery) {
    _query = newQuery;
    _performSearch();
  }

  void updateFilter(SearchFilter newFilter) {
    _selectedFilter = newFilter;
    _performSearch();
  }

  Future<void> _performSearch() async {
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
      _containerResults = await _containerRepository.searchContainers(_query);
    } else {
      _containerResults = [];
    }

    if (_selectedFilter == SearchFilter.all ||
        _selectedFilter == SearchFilter.itemsOnly) {
      _itemResults = await _itemRepository.searchItems(_query);
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
