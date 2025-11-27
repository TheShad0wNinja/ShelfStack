import 'package:flutter/material.dart';

class CreateContainerScreen extends StatefulWidget {
  const CreateContainerScreen({super.key});

  @override
  State<CreateContainerScreen> createState() => _CreateContainerScreenState();
}

class _CreateContainerScreenState extends State<CreateContainerScreen> {
  final _nameController = TextEditingController();
  final _tagController = TextEditingController();
  final _locationLabelController = TextEditingController();
  final List<String> _tags = [];
  String? _locationAddress;

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

  void _createContainer() {
    // Simulate success
    if (!mounted) return;

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Container created successfully (Static)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Container'),
        actions: [
          TextButton(onPressed: _createContainer, child: const Text('Save')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildQRCodePreview(),
            const SizedBox(height: 24),
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
                hintText: 'e.g. Kitchen Supplies',
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
