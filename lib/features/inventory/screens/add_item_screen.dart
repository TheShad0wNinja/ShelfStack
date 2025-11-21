import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/core/widgets/rounded_appbar.dart';
import 'package:shelfstack/features/inventory/viewmodels/containers_viewmodel.dart';
import 'package:shelfstack/features/inventory/viewmodels/add_item_viewmodel.dart';

class AddItemScreen extends StatelessWidget {
  final String containerId;
  final String containerName;
  final String containerLocation;

  const AddItemScreen({
    super.key,
    required this.containerId,
    required this.containerName,
    required this.containerLocation,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddItemViewModel(),
      child: _AddItemContent(
        containerId: containerId,
        containerName: containerName,
        containerLocation: containerLocation,
      ),
    );
  }
}

class _AddItemContent extends StatefulWidget {
  final String containerId;
  final String containerName;
  final String containerLocation;

  const _AddItemContent({
    required this.containerId,
    required this.containerName,
    required this.containerLocation,
  });

  @override
  State<_AddItemContent> createState() => _AddItemContentState();
}

class _AddItemContentState extends State<_AddItemContent> {
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final vm = context.watch<AddItemViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: RoundedAppBar(
        height: 80,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, size: 18),
              ),
            ),
            Text(
              'Add Item',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 32), // Spacer for alignment
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Upload Section
            Center(
              child: GestureDetector(
                onTap: () {
                  // Mock photo upload
                  vm.updatePhotoUrl(
                    'https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=400',
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                    image: vm.photoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(vm.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: vm.photoUrl == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 32,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add Photo',
                              style: textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Container Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adding to Container',
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.containerName,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.containerLocation,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Name Field
            Text('Item Name', style: textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              onChanged: vm.updateName,
              decoration: InputDecoration(
                hintText: 'e.g., Spare Keys',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),

            // Description Field
            Text('Description', style: textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              onChanged: vm.updateDescription,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add details about the item...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),

            // Tags Section
            Text('Tags', style: textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _tagController,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  vm.addTag(value);
                  _tagController.clear();
                }
              },
              decoration: InputDecoration(
                hintText: 'Type and press enter to add tags',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_tagController.text.isNotEmpty) {
                      vm.addTag(_tagController.text);
                      _tagController.clear();
                    }
                  },
                ),
              ),
            ),
            if (vm.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: vm.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => vm.removeTag(tag),
                    backgroundColor: const Color(0xFFE3F2FD),
                    labelStyle: TextStyle(color: theme.colorScheme.primary),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        final containersVm = context
                            .read<ContainersViewModel>();
                        final success = await vm.saveItem(
                          widget.containerId,
                          containersVm,
                        );
                        if (success && context.mounted) {
                          Navigator.of(context).pop();
                        } else if (vm.error != null && context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(vm.error!)));
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: vm.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Item',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
