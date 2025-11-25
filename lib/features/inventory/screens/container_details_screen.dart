import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/core/extensions/string_extensions.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/location.dart';
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/features/inventory/screens/add_item_screen.dart';
import 'package:shelfstack/features/inventory/screens/edit_container_screen.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/features/inventory/viewmodels/container_details_viewmodel.dart';
import 'package:shelfstack/features/inventory/viewmodels/container_edit_viewmodel.dart';
import 'package:shelfstack/features/inventory/widgets/item_card.dart';
import 'package:shelfstack/core/widgets/rounded_appbar.dart';

class ContainerDetailsScreen extends StatelessWidget {
  final String containerId;

  const ContainerDetailsScreen({super.key, required this.containerId});

  @override
  Widget build(BuildContext context) {
    return _ContainerDetailsContent(containerId: containerId);
  }
}

class _ContainerDetailsContent extends StatefulWidget {
  final String containerId;

  const _ContainerDetailsContent({required this.containerId});

  @override
  State<_ContainerDetailsContent> createState() =>
      _ContainerDetailsContentState();
}

class _ContainerDetailsContentState extends State<_ContainerDetailsContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ContainerDetailsViewModel>().loadContainer(
        widget.containerId,
        context.read<ContainerRepository>(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContainerDetailsViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (vm.error != null) {
          return Scaffold(
            body: Center(
              child: Text(
                "Error Loading container: ${vm.error}",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          appBar: RoundedAppBar(
            height: 345,
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 24),
            child: _buildAppBarContent(context, vm.container!),
          ),
          body: _buildBody(context, vm.container!),
        );
      },
    );
  }

  Widget _buildAppBarContent(BuildContext context, models.Container container) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              'Container Details',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.more_vert, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withAlpha(50),
                    width: 2,
                  ),
                  color: Colors.grey.shade100,
                  image: container.photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(container.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: container.photoUrl == null
                    ? const Icon(Icons.qr_code, size: 48, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 14),
              Text(container.name, style: textTheme.titleMedium),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Color(0xFF6A7282),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${container.location.label} - ${container.location.address}',
                    style: textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF6A7282),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '2.5 Km',
                    style: textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildTagSections(container),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.edit_outlined,
                label: 'Edit',
                isPrimary: false,
                onTap: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ChangeNotifierProvider<ContainerEditViewModel>(
                            create: (context) => ContainerEditViewModel(
                              container,
                              context.read<ContainerRepository>(),
                            ),
                            child: EditContainerScreen(container: container),
                          ),
                    ),
                  );

                  if (result == true && context.mounted) {
                    context.read<ContainerDetailsViewModel>().loadContainer(
                      container.id,
                      context.read<ContainerRepository>(),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.add,
                label: 'Add Item',
                isPrimary: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddItemScreen(
                        containerId: container.id,
                        containerName: container.name,
                        containerLocation: container.location.label,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.share_outlined,
                label: 'Share',
                isPrimary: false,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagSections(models.Container container) {
    final tags = container.tags;
    return SizedBox(
      height: 22,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: tags.asMap().entries.map((entry) {
              final index = entry.key;
              final tag = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  right: index != tags.length - 1 ? 10.0 : 0,
                ),
                child: Badge(
                  label: Text(tag.toTitleCase()),
                  backgroundColor: Colors.blue.withAlpha(50),
                  textColor: Colors.blue.shade800,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final color = isPrimary ? theme.colorScheme.primary : Colors.grey.shade200;
    final textColor = isPrimary ? Colors.white : theme.colorScheme.primary;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: textColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: textColor,
                  height: 1.2,
                  letterSpacing: 0.10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, models.Container container) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${container.items.length} Items',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6A7282),
                ),
              ),
              Row(
                children: [
                  Text(
                    'Sort by: ',
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Name',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: container.items.isEmpty
                ? Center(
                    child: Text(
                      'No items in this container',
                      style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: container.items.length,
                    itemBuilder: (context, index) {
                      return ItemCard(
                        item: container.items[index],
                        containerId: container.id,
                        containerName: container.name,
                        containerLocation: container.location.label,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
