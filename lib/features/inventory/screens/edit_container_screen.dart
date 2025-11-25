import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/core/widgets/rounded_appbar.dart';
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: RoundedAppBar(
        height: 88,
        padding: const EdgeInsets.fromLTRB(16, 25, 16, 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, size: 18),
              ),
            ),
            Text(
              'Edit Container',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => context
                  .read<ContainerEditViewModel>()
                  .save(context)
                  .then((_) {
                    if (mounted) {
                      Navigator.of(context).pop(true);
                    }
                  }),
              child: Text(
                'Save',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Container Name *', style: textTheme.bodySmall),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Tags', style: textTheme.bodySmall),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    onSubmitted: (_) => _addTag(),
                    decoration: InputDecoration(
                      hintText: 'Type a tag...',
                      hintStyle: textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: _addTag,
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    backgroundColor: const Color(0xFFE3F2FD),
                    labelStyle: textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF1976D2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0x00ffffff)),
                    ),
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.black,
                ),
                const SizedBox(width: 3),
                Text('Location', style: textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 112,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 28),
              decoration: BoxDecoration(
                color: const Color(0xFFBBDEFB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade500,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _useCurrentLocation,
              icon: const Icon(
                Icons.my_location,
                size: 20,
                color: Colors.white,
              ),
              label: Text(
                'Use Current Location',
                style: textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationLabelController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
              style: textTheme.bodySmall,
            ),
            if (_locationAddress != null) ...[
              const SizedBox(height: 10),
              Text(
                '${widget.container.location.label} - $_locationAddress',
                style: textTheme.labelSmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
