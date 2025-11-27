import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/features/inventory/screens/container_details_screen.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Item item;
  final String containerId;
  final String containerName;
  final String containerLocation;

  const ItemDetailsScreen({
    super.key,
    required this.item,
    required this.containerId,
    required this.containerName,
    required this.containerLocation,
  });

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  bool _isEditing = false;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final _tagController = TextEditingController();
  late List<String> _tags;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _descriptionController = TextEditingController(
      text: widget.item.description ?? '',
    );
    _tags = List.from(widget.item.tags);
    _photoUrl = widget.item.photoUrl;
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

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    _toggleEdit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isEditing
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _toggleEdit,
              )
            : null,
        title: Text(_isEditing ? 'Edit Item' : 'Item Details'),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              tooltip: 'Save',
            )
          else ...[
            IconButton(
              onPressed: _toggleEdit,
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: () {
                // TODO: Implement delete logic
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.delete),
              tooltip: 'Delete',
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNameDescriptionSection(),
            const SizedBox(height: 24),
            _buildPhotoSection(),
            const SizedBox(height: 24),
            _buildTagsSection(),
            const SizedBox(height: 24),
            _buildStoredInSection(),
            const SizedBox(height: 24),
            _buildExternalDocumentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    if (!_isEditing && _photoUrl != null) {
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
                      _photoUrl!,
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
        child: Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            image: DecorationImage(
              image: NetworkImage(_photoUrl!),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

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
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                color: Theme.of(context).colorScheme.surface,
                image: _photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(_photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _photoUrl == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No Photo',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
            if (_isEditing) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Choose'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNameDescriptionSection() {
    if (!_isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item.name,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (widget.item.description != null &&
              widget.item.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.item.description!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      );
    }

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

  Widget _buildTagsSection() {
    if (!_isEditing && _tags.isEmpty) return const SizedBox.shrink();

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
            if (_isEditing) ...[
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
            ],
            if (_tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return InputChip(
                    label: Text(tag),
                    onDeleted: _isEditing ? () => _removeTag(tag) : null,
                    isEnabled: true, // Always enabled to show style
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

  Widget _buildStoredInSection() {
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
                        ContainerDetailsScreen(containerId: widget.containerId),
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
                            widget.containerName,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            widget.containerLocation,
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
            if (_isEditing) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Move Item'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExternalDocumentsSection() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'External Documents',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.link),
                  label: const Text('Link Attachments'),
                ),
              )
            else
              Text(
                'No documents linked.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
