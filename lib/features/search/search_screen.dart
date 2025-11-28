import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';
import 'package:shelfstack/features/search/search_viewmodel.dart';
import 'package:shelfstack/features/search/widgets/search_result_card.dart';

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
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Search',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Search items or containers...',
                            filled: true,
                            fillColor:
                                theme.colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(
                                context,
                                label: 'All',
                                isSelected:
                                    vm.selectedFilter == SearchFilter.all,
                                onSelected: () =>
                                    _onFilterChanged(SearchFilter.all),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                context,
                                label: 'Containers',
                                isSelected:
                                    vm.selectedFilter ==
                                    SearchFilter.containersOnly,
                                onSelected: () => _onFilterChanged(
                                  SearchFilter.containersOnly,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                context,
                                label: 'Items',
                                isSelected:
                                    vm.selectedFilter == SearchFilter.itemsOnly,
                                onSelected: () =>
                                    _onFilterChanged(SearchFilter.itemsOnly),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${vm.totalResults} Results Found',
                              style: textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            // Sort functionality can be added here later
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < vm.containerResults.length) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SearchResultCard.container(
                              container: vm.containerResults[index],
                            ),
                          );
                        } else {
                          final itemIndex = index - vm.containerResults.length;
                          final item = vm.itemResults[itemIndex];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SearchResultCard.item(
                              item: item,
                              containerName: 'Container ${item.containerId}',
                              containerId: item.containerId,
                              containerLocation: 'Unknown Location',
                            ),
                          );
                        }
                      },
                      childCount:
                          vm.containerResults.length + vm.itemResults.length,
                    ),
                  ),
                ),
                // Add some bottom padding for the FAB
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.transparent,
        ),
      ),
      showCheckmark: false,
    );
  }
}
