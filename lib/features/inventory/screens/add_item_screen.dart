import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/features/inventory/viewmodels/add_item_viewmodel.dart';

class AddItemScreen extends StatefulWidget {
  final String containerId;
  final String containerLocationLabel;
  final String containerName;

  const AddItemScreen({
    super.key,
    required this.containerId,
    required this.containerLocationLabel,
    required this.containerName,
  });

  @override
  State createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  ThemeData get theme => Theme.of(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        actions: [
          TextButton(
            onPressed: () async {
              final success = await context.read<AddItemViewModel>().saveItem(
                widget.containerId,
                context.read<ContainerRepository>(),
              );
              if (success && mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
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
              children: [
                if (vm.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      vm.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                _buildNameSection(vm),
                const SizedBox(height: 24),
                _buildDescriptionSection(vm),
                const SizedBox(height: 24),
                _buildTagsSection(vm),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNameSection(AddItemViewModel vm) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item Name', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              onChanged: vm.updateName,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter item name',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(AddItemViewModel vm) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              onChanged: vm.updateDescription,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter item description',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(AddItemViewModel vm) {
    final tagController = TextEditingController();
    return Card(
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
                    controller: tagController,
                    onSubmitted: (value) {
                      vm.addTag(value);
                      tagController.clear();
                    },
                    decoration: InputDecoration(
                      labelText: 'Add Tag',
                      hintText: 'Type a tag...',
                      suffixIcon: IconButton(
                        onPressed: () {
                          vm.addTag(tagController.text);
                          tagController.clear();
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
}
