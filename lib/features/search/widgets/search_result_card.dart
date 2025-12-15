import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/core/widgets/dynamic_image.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';
import 'package:shelfstack/features/inventory/screens/container_details_view.dart';
import 'package:shelfstack/features/inventory/screens/item_details_view.dart';
import 'package:shelfstack/features/inventory/viewmodels/item_details_viewmodel.dart';

class SearchResultCard extends StatelessWidget {
  final models.Container? container;
  final Item? item;
  final String? containerName;
  final String? containerId;
  final String? containerLocation;

  const SearchResultCard.container({super.key, required this.container})
    : item = null,
      containerName = null,
      containerId = null,
      containerLocation = null;

  const SearchResultCard.item({
    super.key,
    required this.item,
    this.containerName,
    this.containerId,
    this.containerLocation,
  }) : container = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (container != null) {
      return _buildCard(
        context,
        type: 'Container',
        title: container!.name,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  ContainerDetailsView(containerId: container!.id),
            ),
          );
        },
        leadingPhotoUrl: container!.photoUrl,
        leadingIcon: Icons.inventory_2_outlined,
        leadingIconColor: theme.colorScheme.onPrimaryContainer,
        leadingColor: theme.colorScheme.primaryContainer,
        details: _buildContainerDetails(context, container!),
      );
    } else if (item != null) {
      return _buildCard(
        context,
        type: 'Item',
        title: item!.name,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (BuildContext context) => ItemDetailsViewModel(
                  item!.id,
                  context.read<ContainerRepository>(),
                  context.read<ItemRepository>(),
                ),
                child: ItemDetailsView(),
              ),
            ),
          );
        },
        leadingPhotoUrl: item!.photoUrl,
        leadingIcon: Icons.hide_image_outlined,
        leadingIconColor: theme.colorScheme.onTertiaryContainer,
        leadingColor: theme.colorScheme.tertiaryContainer,
        details: _buildItemDetails(context),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCard(
    BuildContext context, {
    required String type,
    required String title,
    required VoidCallback onTap,
    String? leadingPhotoUrl,
    required IconData leadingIcon,
    required Color leadingIconColor,
    Color leadingColor = Colors.white,
    required Widget details,
  }) {
    final theme = Theme.of(context);
    final isContainer = type == 'Container';

    return Card(
      margin: const EdgeInsets.symmetric(),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: leadingColor),
                  child: DynamicImage(
                    imageUrl: leadingPhotoUrl,
                    iconSize: 28,
                    iconColor: leadingIconColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _buildTypeTag(context, type, isContainer),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    details,
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTag(BuildContext context, String type, bool isContainer) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = isContainer ? colorScheme.secondary : colorScheme.tertiary;

    return Badge(
      label: Text(type),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }

  Widget _buildContainerDetails(
    BuildContext context,
    models.Container container,
  ) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(Icons.inventory_2_outlined, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          "${container.itemCount} items",
          style: theme.textTheme.bodySmall?.copyWith(color: color),
        ),
        const SizedBox(width: 12),
        Icon(Icons.location_on_outlined, color: color, size: 16),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            container.location.label,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildItemDetails(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;

    return const SizedBox();
  }
}
