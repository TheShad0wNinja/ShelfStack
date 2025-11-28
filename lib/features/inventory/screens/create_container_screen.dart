import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/features/inventory/viewmodels/create_container_viewmodel.dart';

class CreateContainerScreen extends StatelessWidget {
  const CreateContainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateContainerViewModel(),
      child: const _CreateContainerScreenContent(),
    );
  }
}

class _CreateContainerScreenContent extends StatefulWidget {
  const _CreateContainerScreenContent();

  @override
  State<_CreateContainerScreenContent> createState() =>
      _CreateContainerScreenContentState();
}

class _CreateContainerScreenContentState
    extends State<_CreateContainerScreenContent> {
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Container'),
        actions: [
          IconButton(
            onPressed: () async {
              final vm = context.read<CreateContainerViewModel>();
              final success = await vm.createContainer(
                context.read<ContainerRepository>(),
              );
              if (success && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Container created successfully'),
                    backgroundColor: Colors.green,
                  ),
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
      body: Consumer<CreateContainerViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildQRCodePreview(),
                const SizedBox(height: 24),
                _buildNameSection(vm),
                const SizedBox(height: 24),
                _buildTagsSection(vm),
                const SizedBox(height: 24),
                _buildLocationSection(vm),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQRCodePreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'QR Code Preview',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.qr_code,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'QR code will be\ngenerated upon saving',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameSection(CreateContainerViewModel vm) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Container Name',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: vm.updateName,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Kitchen Supplies',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(CreateContainerViewModel vm) {
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
                    controller: _tagController,
                    onSubmitted: (value) {
                      vm.addTag(value);
                      _tagController.clear();
                    },
                    decoration: InputDecoration(
                      labelText: 'Add Tag',
                      hintText: 'Type a tag...',
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

  Widget _buildLocationSection(CreateContainerViewModel vm) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.map,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: vm.useCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Use Current Location'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: vm.updateLocationLabel,
              decoration: const InputDecoration(
                labelText: 'Location Label',
                hintText: 'e.g. Storage Room',
              ),
            ),
            if (vm.locationAddress != null) ...[
              const SizedBox(height: 8),
              Text(
                'Address: ${vm.locationAddress}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
