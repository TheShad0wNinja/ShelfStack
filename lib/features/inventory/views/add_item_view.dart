import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/core/utils/dialog_helper.dart';
import 'package:shelfstack/core/widgets/expandable_dynamic_image.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';
import 'package:shelfstack/features/inventory/viewmodels/add_item_viewmodel.dart';
import 'package:shelfstack/features/inventory/widgets/container_selection_dialog.dart';

class AddItemView extends StatelessWidget {
  final String? containerId;
  final String? containerLocationLabel;
  final String? containerName;

  const AddItemView({
    super.key,
    this.containerId,
    this.containerLocationLabel,
    this.containerName,
  });

  @override
  Widget build(BuildContext context) {
    return _content(context);
  }

  Widget _content(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final vm = AddItemViewModel(
          context.read<ItemRepository>(),
          context.read<ContainerRepository>(),
        );
        if (containerId != null) {
          vm.loadContainer(containerId!);
        }
        return vm;
      },
      child: const _AddItemViewContent(),
    );
  }
}

class _AddItemViewContent extends StatefulWidget {
  const _AddItemViewContent();

  @override
  State<_AddItemViewContent> createState() => _AddItemViewContentState();
}

class _AddItemViewContentState extends State<_AddItemViewContent> {
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _showContainerSelectionDialog() async {
    final vm = context.read<AddItemViewModel>();
    final selectedContainer = await showDialog<models.Container>(
      context: context,
      builder: (context) => ContainerSelectionDialog(
        currentContainerId: vm.selectedContainer?.id,
      ),
    );

    if (selectedContainer != null && mounted) {
      vm.setContainer(selectedContainer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await DialogHelper.confirmDiscard(context);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop(false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Item'),
          actions: [
            IconButton(
              onPressed: () async {
                final vm = context.read<AddItemViewModel>();
                final success = await vm.save();
                if (success && mounted) {
                  Navigator.of(context).pop(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item added successfully')),
                  );
                } else if (mounted && vm.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(vm.error!),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.save),
              tooltip: 'Save',
            ),
          ],
        ),
        body: Consumer<AddItemViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildNameDescriptionSection(vm),
                  const SizedBox(height: 24),
                  _buildPhotoSection(context),
                  const SizedBox(height: 24),
                  _buildTagsSection(vm),
                  const SizedBox(height: 24),
                  _buildStoredInSection(context, vm),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNameDescriptionSection(AddItemViewModel vm) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Details', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              onChanged: vm.updateName,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: vm.updateDescription,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return Consumer<AddItemViewModel>(
      builder: (context, vm, child) {
        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item Photo',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: ExpandableDynamicImage(
                      imageUrl: vm.photoUrl,
                      heroTag: 'add_item_image',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          vm.takePhoto();
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          vm.choosePhoto();
                        },
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Choose'),
                      ),
                    ),
                  ],
                ),
                if (vm.photoUrl != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        vm.updatePhotoUrl(null);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove Photo'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTagsSection(AddItemViewModel vm) {
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    onSubmitted: (value) {
                      vm.addTag(value);
                      _tagController.clear();
                    },
                    decoration: InputDecoration(
                      labelText: 'Add Tag',
                      hintText: 'Type a tag...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          vm.addTag(_tagController.text);
                          _tagController.clear();
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (vm.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: vm.tags.map((tag) {
                  return InputChip(
                    label: Text(tag),
                    onDeleted: () => vm.removeTag(tag),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStoredInSection(BuildContext context, AddItemViewModel vm) {
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
            if (vm.selectedContainer != null)
              Container(
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
                            vm.selectedContainer!.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            vm.selectedContainer!.location.label,
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
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Text(
                    'No container selected',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _showContainerSelectionDialog,
                child: Text(
                  vm.selectedContainer == null
                      ? 'Select Container'
                      : 'Change Container',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
