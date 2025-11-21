import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/features/search/widgets/search_result_card.dart';
import 'package:shelfstack/core/widgets/rounded_appbar.dart';
import 'package:shelfstack/features/inventory/viewmodels/containers_viewmodel.dart';

enum SearchFilter { all, containersOnly, itemsOnly }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  SearchFilter _selectedFilter = SearchFilter.all;
  List<models.Container> _containerResults = [];
  List<Item> _itemResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _containerResults = [];
        _itemResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final containersVm = Provider.of<ContainersViewModel>(
      context,
      listen: false,
    );

    if (_selectedFilter == SearchFilter.all ||
        _selectedFilter == SearchFilter.containersOnly) {
      _containerResults = await containersVm.searchContainers(query);
    } else {
      _containerResults = [];
    }

    if (_selectedFilter == SearchFilter.all ||
        _selectedFilter == SearchFilter.itemsOnly) {
      _itemResults = await containersVm.searchItems(query);
    } else {
      _itemResults = [];
    }

    setState(() {
      _isSearching = false;
    });
  }

  int get _totalResults => _containerResults.length + _itemResults.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: RoundedAppBar(
        height: 214,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search Items or containers...',
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              spacing: 4,
              children: [
                const Icon(Icons.filter_list, size: 18),
                Text('Filters', style: textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              spacing: 10,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedFilter == SearchFilter.all,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilter = SearchFilter.all;
                      });
                      if (_searchController.text.isNotEmpty) {
                        _performSearch(_searchController.text);
                      }
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Containers Only'),
                  selected: _selectedFilter == SearchFilter.containersOnly,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilter = SearchFilter.containersOnly;
                      });
                      if (_searchController.text.isNotEmpty) {
                        _performSearch(_searchController.text);
                      }
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Items Only'),
                  selected: _selectedFilter == SearchFilter.itemsOnly,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilter = SearchFilter.itemsOnly;
                      });
                      if (_searchController.text.isNotEmpty) {
                        _performSearch(_searchController.text);
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 2,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18),
                    Text('Proximity Search', style: textTheme.bodyMedium),
                  ],
                ),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: false,
                    onChanged: (value) {},
                    inactiveThumbColor: Colors.grey.shade400,
                    inactiveTrackColor: Colors.transparent,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_totalResults Results Found',
                  style: textTheme.bodySmall,
                ),
                Row(
                  children: [
                    Text(
                      'Sort by: ',
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Date',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchController.text.isEmpty
                  ? Center(
                      child: Text(
                        'Start typing to search...',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : _totalResults == 0
                  ? Center(
                      child: Text(
                        'No results found',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        ..._containerResults.map((container) {
                          return Column(
                            children: [
                              SearchResultCard.container(container: container),
                              SizedBox(height: 10),
                            ],
                          );
                        }),
                        SizedBox(height: 10),
                        ..._itemResults.map((item) {
                          final containersVm = Provider.of<ContainersViewModel>(
                            context,
                            listen: false,
                          );
                          final containerName =
                              containersVm.getContainerNameById(
                                item.containerId,
                              ) ??
                              'Unknown';
                          final containerLocation =
                              containersVm.getContainerLocationById(
                                item.containerId,
                              ) ??
                              'Unknown';

                          return Column(
                            children: [
                              SearchResultCard.item(
                                item: item,
                                containerName: containerName,
                                containerId: item.containerId,
                                containerLocation: containerLocation,
                              ),
                              SizedBox(height: 10),
                            ],
                          );
                        }),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
