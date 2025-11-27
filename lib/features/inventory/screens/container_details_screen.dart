import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shelfstack/core/extensions/string_extensions.dart';
import 'package:shelfstack/data/models/container.dart' as models;

import 'package:shelfstack/features/inventory/screens/add_item_screen.dart';
import 'package:shelfstack/features/inventory/screens/edit_container_screen.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';
import 'package:shelfstack/features/inventory/viewmodels/add_item_viewmodel.dart';
import 'package:shelfstack/features/inventory/viewmodels/container_details_viewmodel.dart';
import 'package:shelfstack/features/inventory/viewmodels/container_edit_viewmodel.dart';
import 'package:shelfstack/features/inventory/widgets/item_card.dart';

class ContainerDetailsScreen extends StatelessWidget {
  final String containerId;

  const ContainerDetailsScreen({super.key, required this.containerId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ContainerDetailsViewModel(),
      child: _ContainerDetailsContent(containerId: containerId),
    );
  }
}

class _ContainerDetailsContent extends StatefulWidget {
  final String containerId;

  const _ContainerDetailsContent({required this.containerId});

  @override
  State<_ContainerDetailsContent> createState() =>
      _ContainerDetailsContentState();
}

class _ContainerDetailsContentState extends State<_ContainerDetailsContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadContainer(),
    );
  }

  void _loadContainer() {
    context.read<ContainerDetailsViewModel>().loadContainer(
      widget.containerId,
      context.read<ContainerRepository>(),
      context.read<ItemRepository>(),
    );
  }

  void _showSortModal(BuildContext context) {
    final vm = context.read<ContainerDetailsViewModel>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _SortBottomSheet(
        currentSortBy: vm.sortBy,
        currentSortOrder: vm.sortOrder,
        onApply: (sortBy, sortOrder) {
          vm.setSortOptions(sortBy, sortOrder);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContainerDetailsViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (vm.error != null) {
          return Scaffold(
            body: Center(
              child: Text(
                "Error Loading container: ${vm.error}",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          );
        }
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                stretch: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  vm.container!.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (context) => AddItemViewModel(),
                            child: AddItemScreen(
                              containerId: vm.container!.id,
                              containerLocationLabel:
                                  vm.container!.location.label,
                              containerName: vm.container!.name,
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    color: Colors.black,
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.black),
                    onSelected: (value) async {
                      if (value == 'share') {
                        // Implement share functionality
                      } else if (value == 'edit') {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ChangeNotifierProvider<ContainerEditViewModel>(
                                  create: (context) => ContainerEditViewModel(
                                    vm.container!,
                                    context.read<ContainerRepository>(),
                                  ),
                                  child: EditContainerScreen(
                                    container: vm.container!,
                                  ),
                                ),
                          ),
                        );

                        if (result == true && context.mounted) {
                          _loadContainer();
                          // context
                          //     .read<ContainerDetailsViewModel>()
                          //     .loadContainer(
                          //       vm.container!.id,
                          //       context.read<ContainerRepository>(),
                          //       context.read<ItemRepository>(),
                          //     );
                        }
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Container'),
                            content: const Text(
                              'Are you sure you want to delete this container? This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          await context
                              .read<ContainerDetailsViewModel>()
                              .deleteContainer(
                                vm.container!.id,
                                context.read<ContainerRepository>(),
                              );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.share_outlined),
                              SizedBox(width: 8),
                              Text('Share'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            image: vm.container!.photoUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(
                                      vm.container!.photoUrl!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: vm.container!.photoUrl == null
                              ? Icon(
                                  Icons.inventory_2_outlined,
                                  size: 48,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                )
                              : null,
                        ),
                        const SizedBox(height: 10),
                        _buildInfoSection(context, vm.container!),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_buildItemsHeader(context, vm.container!)],
                  ),
                ),
              ),
              if (vm.sortedItems.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No items in this container',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return ItemCard(
                        item: vm.sortedItems[index],
                        containerId: vm.container!.id,
                        containerName: vm.container!.name,
                        containerLocationLabel: vm.container!.location.label,
                        onUpdateItem: () => _loadContainer(),
                      );
                    }, childCount: vm.sortedItems.length),
                  ),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(BuildContext context, models.Container container) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              '${container.location.label} • ${container.location.address}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: container.tags.map((tag) {
            return Chip(
              label: Text(tag.toTitleCase()),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildItemsHeader(BuildContext context, models.Container container) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${container.items.length} ${container.items.length == 1 ? "item" : "items"}',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton.icon(
          onPressed: () => _showSortModal(context),
          icon: const Icon(Icons.sort),
          label: const Text('Sort'),
        ),
      ],
    );
  }
}

class _SortBottomSheet extends StatefulWidget {
  final SortBy currentSortBy;
  final SortOrder currentSortOrder;
  final Function(SortBy, SortOrder) onApply;

  const _SortBottomSheet({
    required this.currentSortBy,
    required this.currentSortOrder,
    required this.onApply,
  });

  @override
  State<_SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<_SortBottomSheet> {
  late SortBy _selectedSortBy;
  late SortOrder _selectedSortOrder;

  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.currentSortBy;
    _selectedSortOrder = widget.currentSortOrder;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                'Sort Items',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Sort by',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            RadioGroup<SortBy>(
              groupValue: _selectedSortBy,
              onChanged: (SortBy? value) => setState(() {
                _selectedSortBy = value!;
              }),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Name'),
                    leading: Radio<SortBy>(value: SortBy.name),
                  ),
                  ListTile(
                    title: Text('Date Added'),
                    leading: Radio<SortBy>(value: SortBy.dateAdded),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Order',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            RadioGroup<SortOrder>(
              groupValue: _selectedSortOrder,
              onChanged: (SortOrder? value) => setState(() {
                _selectedSortOrder = value!;
              }),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Ascending'),
                    subtitle: Text(
                      _selectedSortBy == SortBy.name
                          ? 'A to Z'
                          : 'Oldest first',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    leading: Radio<SortOrder>(value: SortOrder.ascending),
                  ),
                  ListTile(
                    title: const Text('Descending'),
                    subtitle: Text(
                      _selectedSortBy == SortBy.name
                          ? 'Z to A'
                          : 'Newest first',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    leading: Radio<SortOrder>(value: SortOrder.descending),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: FilledButton(
                onPressed: () {
                  widget.onApply(_selectedSortBy, _selectedSortOrder);
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
