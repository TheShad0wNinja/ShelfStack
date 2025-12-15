import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/core/utils/dialog_helper.dart';
import 'package:shelfstack/core/widgets/expandable_dynamic_image.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';
import 'package:shelfstack/features/inventory/viewmodels/edit_item_viewmodel.dart';
import 'package:shelfstack/features/inventory/widgets/container_selection_dialog.dart';

class EditItemView extends StatelessWidget {
  final Item item;
  final models.Container container;

  const EditItemView({
    super.key,
    required this.item,
    required this.container,
  });

  @override
  Widget build(BuildContext context) {
    return _content(context);
  }

  Widget _content(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditItemViewModel(
        context.read<ItemRepository>(),
        context.read<ContainerRepository>(),
        item,
        container,
      ),
      child: _EditItemViewContent(),
    );
  }
}

class _EditItemViewContent extends StatefulWidget {
  const _EditItemViewContent();

  @override
  State<_EditItemViewContent> createState() => _EditItemViewContentState();
}

class _EditItemViewContentState extends State<_EditItemViewContent> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final _tagController = TextEditingController();
  bool _didUpdate = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<EditItemViewModel>();
    _nameController = TextEditingController(text: vm.name);
    _descriptionController = TextEditingController(text: vm.description ?? '');

    _nameController.addListener(() {
      vm.updateName(_nameController.text);
      _markAsChanged();
    });

    _descriptionController.addListener(() {
      vm.updateDescription(_descriptionController.text);
      _markAsChanged();
    });
  }

  void _markAsChanged() {
    if (!_didUpdate) {
      setState(() {
        _didUpdate = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    final vm = context.read<EditItemViewModel>();
    if (tag.isNotEmpty && !vm.tags.contains(tag)) {
      final newTags = List<String>.from(vm.tags)..add(tag);
      vm.updateTags(newTags);
      _tagController.clear();
      _markAsChanged();
    }
  }

  void _removeTag(String tag) {
    final vm = context.read<EditItemViewModel>();
    final newTags = List<String>.from(vm.tags)..remove(tag);
    vm.updateTags(newTags);
    _markAsChanged();
  }

  Future<void> _saveChanges() async {
    final vm = context.read<EditItemViewModel>();
    final success = await vm.save();

    if (success && mounted) {
      _didUpdate = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item updated successfully')),
      );
      Navigator.of(context).pop(true);
    } else if (mounted && vm.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${vm.error}')));
    }
  }

  Future<void> _showMoveItemDialog() async {
    final vm = context.read<EditItemViewModel>();

    if (!mounted) return;

    final selectedContainer = await showDialog<models.Container>(
      context: context,
      builder: (context) =>
          ContainerSelectionDialog(currentContainerId: vm.selectedContainer.id),
    );

    if (selectedContainer != null &&
        selectedContainer.id != vm.selectedContainer.id &&
        mounted) {
      vm.updateContainer(selectedContainer);
      _markAsChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_didUpdate,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await DialogHelper.confirmDiscard(context);

        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop(false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Item'),
          actions: [
            IconButton(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              tooltip: 'Save',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Consumer<EditItemViewModel>(
            builder: (context, vm, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildNameDescriptionSection(vm),
                  const SizedBox(height: 24),
                  _buildPhotoSection(vm),
                  const SizedBox(height: 24),
                  _buildTagsSection(vm),
                  const SizedBox(height: 24),
                  _buildStoredInSection(vm),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNameDescriptionSection(EditItemViewModel vm) {
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
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
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

  Widget _buildPhotoSection(EditItemViewModel vm) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item Photo', style: Theme.of(context).textTheme.titleMedium),
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
                  heroTag: 'item_edit_${vm.item.id}_image',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      _markAsChanged();
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
                      _markAsChanged();
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
                    _markAsChanged();
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
  }

  Widget _buildTagsSection(EditItemViewModel vm) {
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
                    onSubmitted: (_) => _addTag(),
                    decoration: InputDecoration(
                      labelText: 'Add Tag',
                      hintText: 'Type a tag...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: _addTag,
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (vm.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: vm.tags.map((tag) {
                  return InputChip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                  );
                }).toList(),
              )
            else
              Text(
                'No tags added.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoredInSection(EditItemViewModel vm) {
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
                          vm.selectedContainer.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          vm.selectedContainer.location.label,
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
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _showMoveItemDialog,
                child: const Text('Move Item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
