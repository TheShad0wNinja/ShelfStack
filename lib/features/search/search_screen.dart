import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/features/search/widgets/search_result_card.dart';
import 'package:shelfstack/core/widgets/rounded_appbar.dart';
import 'package:shelfstack/features/inventory/viewmodels/containers_viewmodel.dart';
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
    // Initialize controller with current query if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<SearchViewModel>();
      if (vm.query.isNotEmpty) {
        _searchController.text = vm.query;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final containersVm = context.read<ContainersViewModel>();

    return Scaffold(
      appBar: RoundedAppBar(
        height: 214,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<SearchViewModel>(
              builder: (context, vm, child) {
                return TextField(
                  controller: _searchController,
                  onChanged: (value) => vm.updateQuery(value, containersVm),
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
                    suffixIcon: vm.query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              vm.clearSearch();
                            },
                          )
                        : null,
                  ),
                );
              },
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
            Consumer<SearchViewModel>(
              builder: (context, vm, child) {
                return Row(
                  spacing: 10,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: vm.selectedFilter == SearchFilter.all,
                      onSelected: (selected) {
                        if (selected) {
                          vm.updateFilter(SearchFilter.all, containersVm);
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Containers Only'),
                      selected:
                          vm.selectedFilter == SearchFilter.containersOnly,
                      onSelected: (selected) {
                        if (selected) {
                          vm.updateFilter(
                            SearchFilter.containersOnly,
                            containersVm,
                          );
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Items Only'),
                      selected: vm.selectedFilter == SearchFilter.itemsOnly,
                      onSelected: (selected) {
                        if (selected) {
                          vm.updateFilter(SearchFilter.itemsOnly, containersVm);
                        }
                      },
                    ),
                  ],
                );
              },
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
        child: Consumer<SearchViewModel>(
          builder: (context, vm, child) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${vm.totalResults} Results Found',
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
                  child: vm.isSearching
                      ? const Center(child: CircularProgressIndicator())
                      : vm.query.isEmpty
                      ? Center(
                          child: Text(
                            'Start typing to search...',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : vm.totalResults == 0
                      ? Center(
                          child: Text(
                            'No results found',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 100),
                          children: [
                            ...vm.containerResults.map((container) {
                              return Column(
                                children: [
                                  SearchResultCard.container(
                                    container: container,
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              );
                            }),
                            const SizedBox(height: 10),
                            ...vm.itemResults.map((item) {
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
                                  const SizedBox(height: 10),
                                ],
                              );
                            }),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
