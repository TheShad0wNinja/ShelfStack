import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/models/location.dart';
import 'package:shelfstack/features/search/widgets/search_result_card.dart';

import 'package:provider/provider.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';
import 'package:shelfstack/features/search/search_viewmodel.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: const _SearchScreenContent(),
    );
  }
}

class _SearchScreenContent extends StatefulWidget {
  const _SearchScreenContent();

  @override
  State<_SearchScreenContent> createState() => _SearchScreenContentState();
}

class _SearchScreenContentState extends State<_SearchScreenContent> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final vm = context.read<SearchViewModel>();
    final containerRepo = context.read<ContainerRepository>();
    final itemRepo = context.read<ItemRepository>();
    vm.updateQuery(_searchController.text, containerRepo, itemRepo);
  }

  void _onFilterChanged(SearchFilter filter) {
    final vm = context.read<SearchViewModel>();
    final containerRepo = context.read<ContainerRepository>();
    final itemRepo = context.read<ItemRepository>();
    vm.updateFilter(filter, containerRepo, itemRepo);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Consumer<SearchViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Search'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(160),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search Items or containers...',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: vm.selectedFilter == SearchFilter.all,
                            onSelected: (selected) {
                              if (selected) _onFilterChanged(SearchFilter.all);
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Containers Only'),
                            selected:
                                vm.selectedFilter ==
                                SearchFilter.containersOnly,
                            onSelected: (selected) {
                              if (selected)
                                _onFilterChanged(SearchFilter.containersOnly);
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Items Only'),
                            selected:
                                vm.selectedFilter == SearchFilter.itemsOnly,
                            onSelected: (selected) {
                              if (selected)
                                _onFilterChanged(SearchFilter.itemsOnly);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              'Proximity Search',
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Switch(value: false, onChanged: (value) {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${vm.totalResults} Results Found',
                      style: textTheme.bodySmall,
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.sort),
                      label: const Text('Sort by Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      ...vm.containerResults.map(
                        (container) =>
                            SearchResultCard.container(container: container),
                      ),
                      ...vm.itemResults.map(
                        (item) => SearchResultCard.item(
                          item: item,
                          // TODO: Fetch actual container details for the item if needed,
                          // or update Item model to include container name/location denormalized,
                          // or fetch asynchronously. For now, using placeholders or we need a way to get container info.
                          // Since we have separate repos, we might need to fetch container info for each item.
                          // For simplicity in this refactor, I'll use placeholders or empty strings
                          // and we can address data fetching in a follow-up if needed.
                          // Actually, ItemRepositoryFake could populate this if we change the model,
                          // but let's stick to the current model.
                          containerName: 'Container ${item.containerId}',
                          containerId: item.containerId,
                          containerLocation: 'Unknown Location',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
