import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelfstack/features/map/screens/location_picker_view.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/core/utils/dialog_helper.dart';
import 'package:shelfstack/core/widgets/expandable_dynamic_image.dart';
import 'package:shelfstack/data/models/container.dart' as models;

import 'package:shelfstack/features/inventory/viewmodels/edit_container_viewmodel.dart';

class EditContainerView extends StatefulWidget {
  final models.Container container;

  const EditContainerView({super.key, required this.container});

  @override
  State<EditContainerView> createState() => _EditContainerScreenState();
}

class _EditContainerScreenState extends State<EditContainerView> {
  late final TextEditingController _nameController;
  late final TextEditingController _locationLabelController;
  final _tagController = TextEditingController();
  late List<String> _tags;
  String? _photoUrl;

  bool _didUpdate = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.container.name);
    _locationLabelController = TextEditingController(
      text: widget.container.location.label,
    );
    _tags = List.from(widget.container.tags);
    _photoUrl = widget.container.photoUrl;

    _nameController.addListener(
      () => context.read<EditContainerViewModel>().updateName(
        _nameController.text,
      ),
    );
    _nameController.addListener(
      () => setState(() {
        _didUpdate = true;
      }),
    );

    _locationLabelController.addListener(
      () => context.read<EditContainerViewModel>().updateLocationLabel(
        _locationLabelController.text,
      ),
    );
    _locationLabelController.addListener(
      () => setState(() {
        _didUpdate = true;
      }),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    _locationLabelController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
        _didUpdate = true;
      });
      context.read<EditContainerViewModel>().updateTags(_tags);
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      _didUpdate = true;
    });
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
          title: const Text('Edit Container'),
          actions: [
            IconButton(
              tooltip: 'Save',
              icon: const Icon(Icons.save),
              onPressed: () async {
                try {
                  await context.read<EditContainerViewModel>().save(context);
                  if (mounted) {
                    Navigator.of(context).pop(true);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error saving container: $e'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildPhotoSection(),
              const SizedBox(height: 24),
              _buildNameSection(),
              const SizedBox(height: 24),
              _buildTagsSection(),
              const SizedBox(height: 24),
              _buildLocationSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
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
              child: Selector<EditContainerViewModel, String?>(
                selector: (context, vm) => vm.photoUrl,
                builder:
                    (BuildContext context, String? photoUrl, Widget? child) =>
                        ExpandableDynamicImage(imageUrl: photoUrl),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _didUpdate = true;
                      });
                      context.read<EditContainerViewModel>().takePhoto();
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _didUpdate = true;
                      });
                      context.read<EditContainerViewModel>().choosePhoto();
                    },
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Choose'),
                  ),
                ),
              ],
            ),
            if (_photoUrl != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _photoUrl = null;
                      _didUpdate = true;
                    });
                    context.read<EditContainerViewModel>().updatePhotoUrl(null);
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

  Widget _buildNameSection() {
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
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter container name',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
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
                    onSubmitted: (_) => _addTag(),
                    decoration: InputDecoration(
                      labelText: 'Add Tag',
                      hintText: 'Type a tag...',
                      suffixIcon: IconButton(
                        onPressed: _addTag,
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return InputChip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<dynamic> _openLocationPicker(EditContainerViewModel vm) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationPickerView(
          initialLocation: vm.location != null && vm.location!.latitude != 0
              ? LatLng(vm.location!.latitude, vm.location!.longitude)
              : null,
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Consumer<EditContainerViewModel>(
              builder: (context, vm, child) {
                return InkWell(
                  onTap: vm.addressLoading
                      ? null
                      : () async {
                          final result = await _openLocationPicker(vm);
                          if (result is LatLng) {
                            vm.updateLocation(result);
                          }
                        },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: vm.location != null && vm.location!.latitude != 0
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                Text(
                                  '${vm.location!.latitude.toStringAsFixed(4)}, ${vm.location!.longitude.toStringAsFixed(4)}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            )
                          : Icon(
                              Icons.map,
                              size: 48,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Consumer<EditContainerViewModel>(
                builder: (context, vm, child) {
                  return FilledButton.tonalIcon(
                    onPressed: vm.addressLoading
                        ? null
                        : () async {
                            final result = await _openLocationPicker(vm);
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
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryFixedDim,
                            ),
                          )
                        : const Icon(Icons.map),
                    label: const Text('Select on Map'),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Consumer<EditContainerViewModel>(
              builder: (context, vm, child) {
                return Column(
                  children: [
                    TextField(
                      controller: _locationLabelController,
                      decoration: const InputDecoration(
                        labelText: 'Location Label',
                        hintText: 'e.g. Storage Room',
                      ),
                    ),
                    if (vm.location != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Address: ${vm.location?.address ?? "Unknown Address"}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
