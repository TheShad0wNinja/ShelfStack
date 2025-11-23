import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/location.dart';
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/features/inventory/screens/add_item_screen.dart';
import 'package:shelfstack/features/inventory/screens/edit_container_screen.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final container = models.Container(
      id: widget.containerId,
      name: 'Static Container Details',
      tags: ['static', 'details'],
      location: Location(
        latitude: 0,
        longitude: 0,
        label: 'Static Location',
        address: '123 Static St',
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: [
        Item(
          id: '1',
          name: 'Static Item 1',
          containerId: widget.containerId,
          tags: ['item'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Item(
          id: '2',
          name: 'Static Item 2',
          containerId: widget.containerId,
          tags: ['item'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: RoundedAppBar(
        height: 345,
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 24),
        child: _buildAppBarContent(context, container),
      ),
      body: _buildBody(context, container),
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
                  border: Border.all(color: const Color(0xFFE3F2FD), width: 2),
                  color: Colors.grey.shade100,
                  image: container.photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(
                            "https://sp-ao.shortpixel.ai/client/to_webp,q_glossy,ret_img,w_300,h_300/https://prooftag.net/wp-content/uploads/2021/07/QR-Code.png",
                          ),
                          fit: BoxFit.fitWidth,
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
              const SizedBox(height: 4),
              if (container.tags.isNotEmpty)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: container.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF1976D2),
                          height: 1.4,
                          letterSpacing: 0.10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.edit_outlined,
                label: 'Edit',
                isPrimary: false,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          EditContainerScreen(container: container),
                    ),
                  );
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
