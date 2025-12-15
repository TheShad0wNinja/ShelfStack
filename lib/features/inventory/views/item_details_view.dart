import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/core/widgets/expandable_dynamic_image.dart';
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';
import 'package:shelfstack/features/inventory/views/container_details_view.dart';
import 'package:shelfstack/features/inventory/views/edit_item_view.dart';
import 'package:shelfstack/features/inventory/viewmodels/edit_item_viewmodel.dart';
import 'package:shelfstack/features/inventory/viewmodels/item_details_viewmodel.dart';

class ItemDetailsView extends StatelessWidget {
  const ItemDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ItemDetailsViewContent();
  }
}

class _ItemDetailsViewContent extends StatefulWidget {
  const _ItemDetailsViewContent();

  @override
  State<_ItemDetailsViewContent> createState() => _ItemDetailsViewContentState();
}

class _ItemDetailsViewContentState extends State<_ItemDetailsViewContent> {
  bool _didUpdate = false;

  Future<void> _navigateToEdit() async {
    final vm = context.read<ItemDetailsViewModel>();
    if (vm.isLoading || vm.error != null) return;

    final item = vm.item!;
    final container = vm.container!;

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => EditItemViewModel(
            context.read<ItemRepository>(),
            context.read<ContainerRepository>(),
            item,
            container,
          ),
          child: EditItemView(item: item, container: container),
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _didUpdate = true;
      });
      vm.loadItem();
    }
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final vm = context.read<ItemDetailsViewModel>();

      final success = await vm.deleteItem();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Deleted item successfully")),
        );
        Navigator.of(context).pop(true);
      } else if (mounted && vm.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${vm.error}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_didUpdate);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Item Details'),
          actions: [
            IconButton(
              onPressed: _navigateToEdit,
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: _deleteItem,
              icon: const Icon(Icons.delete),
              tooltip: 'Delete',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Consumer<ItemDetailsViewModel>(
            builder: (context, vm, child) {
              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (vm.error != null) {
                return Center(child: Text('Error: ${vm.error}'));
              }

              final item = vm.item!;
              final container = vm.container!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildNameDescriptionSection(item),
                  const SizedBox(height: 24),
                  if (item.photoUrl != null) ...[
                    _buildPhotoSection(item),
                    const SizedBox(height: 24),
                  ],
                  if (item.tags.isNotEmpty) ...[
                    _buildTagsSection(item),
                    const SizedBox(height: 24),
                  ],
                  _buildStoredInSection(container),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNameDescriptionSection(Item item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (item.description != null && item.description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            item.description!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoSection(Item item) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    item.photoUrl!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton.filled(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: ExpandableDynamicImage(
            imageUrl: item.photoUrl!,
            heroTag: 'item_${item.id}_image',
          ),
        ),
      ),
    );
  }

  Widget _buildTagsSection(Item item) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tags', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.tags.map((tag) {
                return Chip(label: Text(tag));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoredInSection(models.Container container) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stored In', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ContainerDetailsView(containerId: container.id),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            container.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            container.location.label,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
