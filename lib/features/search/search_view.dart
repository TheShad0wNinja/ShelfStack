import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';
import 'package:shelfstack/features/search/search_viewmodel.dart';
import 'package:shelfstack/features/search/widgets/search_result_card.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  Widget _content(BuildContext context) {
    final containerRepo = context.read<ContainerRepository>();
    final itemRepo = context.read<ItemRepository>();

    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(containerRepo, itemRepo),
      child: const _SearchViewContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _content(context);
  }
}

class _SearchViewContent extends StatefulWidget {
  const _SearchViewContent();

  @override
  State<_SearchViewContent> createState() => _SearchViewContentState();
}

class _SearchViewContentState extends State<_SearchViewContent> {
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
    vm.updateQuery(_searchController.text);
  }

  void _onFilterChanged(SearchFilter filter) {
    final vm = context.read<SearchViewModel>();
    vm.updateFilter(filter);
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
                                theme.colorScheme.surfaceContainer,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
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
                            child: SearchResultCard.item(item: item),
                          );
                        }
                      },
                      childCount: vm.containerResults.length + vm.itemResults.length,
                    ),
                  ),
                ),
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
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      // backgroundColor: theme.colorScheme.surfaceContainerHighest,
      // selectedColor: theme.colorScheme.primaryContainer,
      // labelStyle: TextStyle(
      //   color: isSelected
      //       ? theme.colorScheme.onPrimaryContainer
      //       : theme.colorScheme.onSurfaceVariant,
      //   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      // ),
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(20),
      //   side: BorderSide(
      //     color: isSelected ? Colors.transparent : Colors.transparent,
      //   ),
      // ),
      // showCheckmark: false,
    );
  }
}
