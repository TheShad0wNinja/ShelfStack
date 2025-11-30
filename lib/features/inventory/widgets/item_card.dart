import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/core/extensions/string_extensions.dart';
import 'package:shelfstack/core/widgets/dynamic_image.dart';
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';
import 'package:shelfstack/features/inventory/screens/item_details_screen.dart';
import 'package:shelfstack/features/inventory/viewmodels/item_details_viewmodel.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final String containerId;
  final String containerName;
  final String containerLocationLabel;
  final void Function() onUpdateItem;

  const ItemCard({
    super.key,
    required this.item,
    required this.containerId,
    required this.containerName,
    required this.containerLocationLabel,
    required this.onUpdateItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (BuildContext context) => ItemDetailsViewModel(
                  item.id,
                  context.read<ContainerRepository>(),
                  context.read<ItemRepository>()
                ),
                child: ItemDetailsScreen()
              ),
            ),
          );

          if (result == true) {
            onUpdateItem();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: DynamicImage(imageUrl: item.photoUrl, iconColor: theme.colorScheme.onSurfaceVariant,)
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.name,
                style: textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: item.tags.take(2).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag.toTitleCase(),
                        style: textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
