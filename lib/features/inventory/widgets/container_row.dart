import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/core/extensions/string_extensions.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/features/inventory/screens/container_details_screen.dart';
import 'package:shelfstack/features/inventory/viewmodels/container_details_viewmodel.dart';

class ContainerRow extends StatelessWidget {
  final models.Container container;

  const ContainerRow({super.key, required this.container});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (_) => ContainerDetailsViewModel(),
                child: ContainerDetailsScreen(containerId: container.id),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surfaceContainerHighest,
                  image: container.photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(container.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: container.photoUrl == null
                    ? Icon(
                        Icons.inventory_2_outlined,
                        size: 32,
                        color: theme.colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(container.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${container.items.length} items",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          container.location.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (container.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _tagSections(context),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tagSections(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: container.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            tag.toTitleCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        );
      }).toList(),
    );
  }
}
