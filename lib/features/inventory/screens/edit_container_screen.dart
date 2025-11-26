import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/data/models/container.dart' as models;

import 'package:shelfstack/features/inventory/viewmodels/container_edit_viewmodel.dart';

class EditContainerScreen extends StatefulWidget {
  final models.Container container;

  const EditContainerScreen({super.key, required this.container});

  @override
  State<EditContainerScreen> createState() => _EditContainerScreenState();
}

class _EditContainerScreenState extends State<EditContainerScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _locationLabelController;
  final _tagController = TextEditingController();
  late List<String> _tags;
  String? _locationAddress;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.container.name);
    _locationLabelController = TextEditingController(
      text: widget.container.location.label,
    );
    _tags = List.from(widget.container.tags);
    _locationAddress = widget.container.location.address;

    _nameController.addListener(
      () => context.read<ContainerEditViewModel>().updateName(
        _nameController.text,
      ),
    );
    _locationLabelController.addListener(
      () => context.read<ContainerEditViewModel>().updateLocationLabel(
        _locationLabelController.text,
      ),
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
      });
      context.read<ContainerEditViewModel>().updateTags(_tags);
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _useCurrentLocation() {
    setState(() {
      _locationAddress = '123 Street, Storage room';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Container'),
        actions: [
          TextButton(
            onPressed: () =>
                context.read<ContainerEditViewModel>().save(context).then((_) {
                  if (mounted) {
                    Navigator.of(context).pop(true);
                  }
                }),
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildNameSection(),
            const SizedBox(height: 24),
            _buildTagsSection(),
            const SizedBox(height: 24),
            _buildLocationSection(),
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

  Widget _buildLocationSection() {
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
                onPressed: _useCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Use Current Location'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationLabelController,
              decoration: const InputDecoration(
                labelText: 'Location Label',
                hintText: 'e.g. Storage Room',
              ),
            ),
            if (_locationAddress != null) ...[
              const SizedBox(height: 8),
              Text(
                'Address: $_locationAddress',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
