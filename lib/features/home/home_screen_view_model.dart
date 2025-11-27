import 'package:flutter/material.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/models/container.dart' as models;

class HomeScreenViewModel extends ChangeNotifier {
  final ContainerRepository _containerRepository;
  final ItemRepository _itemRepository;

  bool _isLoadingInfo = true;
  bool get isLoadingInfo => _isLoadingInfo;

  bool _isLoadingContainers = true;
  bool get isLoadingContainers => _isLoadingContainers;

  int _totalContainers = 0;
  int get totalContainers => _totalContainers;

  int _totalItems = 0;
  int get totalItems => _totalItems;

  List<models.Container> _recentContainers = [];
  List<models.Container> get recentContainers => _recentContainers;

  HomeScreenViewModel(this._containerRepository, this._itemRepository) {
    loadData();
  }

  void loadData() async {
    _isLoadingInfo = true;
    _isLoadingContainers = true;
    notifyListeners();

    _totalContainers = await _containerRepository.fetchTotalContainerCount();
    _totalItems = await _itemRepository.fetchTotalItemCount();
    _isLoadingInfo = false;
    notifyListeners();

    _recentContainers = await _containerRepository.fetchRecentContainers(4);
    _isLoadingContainers = false;
    notifyListeners();
  }
}
