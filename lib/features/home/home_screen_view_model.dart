import 'package:flutter/material.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';

import '../../data/models/container.dart' as models;

class HomeScreenViewModel extends ChangeNotifier {
  final ContainerRepository _repository;

  bool _isLoadingInfo = false;
  bool get isLoadingInfo => _isLoadingInfo;

  bool _isLoadingContainers = false;
  bool get isLoadingContainers => _isLoadingContainers;

  int _totalContainers = 0;
  int get totalContainers => _totalContainers;

  int _totalItems = 0;
  int get totalItems => _totalItems;

  List<models.Container> _recentContainers = [];
  List<models.Container> get recentContainers => _recentContainers;


  HomeScreenViewModel(this._repository) {
    loadData();
  }

  void loadData() async {
    _isLoadingInfo = true;
    _isLoadingContainers = true;
    notifyListeners();

    print("PRINTING");

    _totalContainers = await _repository.getTotalContainerCount();
    _totalItems = await _repository.getTotalItemCount();
    _isLoadingInfo = false;
    notifyListeners();

    _recentContainers = await _repository.fetchRecentContainers(4);
    _isLoadingContainers = false;
    notifyListeners();
  }
}