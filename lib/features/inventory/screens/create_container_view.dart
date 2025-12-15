import 'package:flutter/material.dart' hide FileImage;
import 'package:latlong2/latlong.dart';
import 'package:shelfstack/core/widgets/expandable_dynamic_image.dart';
import 'package:shelfstack/features/map/screens/location_picker_view.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/core/utils/dialog_helper.dart';

import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/features/inventory/viewmodels/create_container_viewmodel.dart';

class CreateContainerView extends StatelessWidget {
  const CreateContainerView({super.key});

  Widget _content(BuildContext context) {
    final containerRepo = context.read<ContainerRepository>();

    return ChangeNotifierProvider(
      create: (_) => CreateContainerViewModel(containerRepo),
      child: const _CreateContainerScreenContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _content(context);
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
          title: const Text('Create Container'),
          actions: [
            IconButton(
              onPressed: () async {
                final vm = context.read<CreateContainerViewModel>();
                final success = await vm.createContainer();
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
                  _buildPhotoSection(vm),
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
      ),
    );
  }

  Widget _buildPhotoSection(CreateContainerViewModel vm) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Container Photo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: ExpandableDynamicImage(
                imageUrl: vm.photoUrl,
                heroTag: 'create_container_image',
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
            InkWell(
              onTap: vm.addressLoading
                  ? null
                  : () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LocationPickerView(),
                        ),
                      );
                      if (result is LatLng) {
                        vm.updateLocation(result);
                      }
                    },
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: vm.selectedLocation != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 48,
                              color: Colors.red,
                            ),
                            Text(
                              '${vm.selectedLocation!.latitude.toStringAsFixed(4)}, ${vm.selectedLocation!.longitude.toStringAsFixed(4)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        )
                      : Icon(
                          Icons.map,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: vm.addressLoading
                    ? null
                    : () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LocationPickerView(),
                          ),
                        );
                        if (result is LatLng) {
                          vm.updateLocation(result);
                        }
                      },
                icon: vm.addressLoading
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: Theme.of(context).colorScheme.primaryFixedDim,
                        ),
                      )
                    : const Icon(Icons.map),
                label: const Text('Select on Map'),
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
            if (vm.selectedLocation != null) ...[
              const SizedBox(height: 8),
              Text(
                'Address: ${vm.locationAddress ?? "Unknown Address"}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
