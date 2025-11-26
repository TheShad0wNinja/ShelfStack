import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/features/inventory/screens/edit_item_screen.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final String containerId;
  final String containerName;
  final String containerLocationLabel;

  const ItemCard({
    super.key,
    required this.item,
    required this.containerId,
    required this.containerName,
    required this.containerLocationLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditItemScreen(
                item: item,
                containerId: containerId,
                containerName: containerName,
                containerLocation: containerLocationLabel,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.colorScheme.surfaceContainerHighest,
                    image: item.photoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(item.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: item.photoUrl == null
                      ? Center(
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : null,
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
                  children: item.tags.take(3).map((tag) {
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
                        tag,
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
