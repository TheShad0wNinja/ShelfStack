import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/features/inventory/screens/container_details_screen.dart';

class ActivityRow extends StatelessWidget {
  final models.Container container;

  const ActivityRow({super.key, required this.container});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  ContainerDetailsScreen(containerId: container.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade300,
                  image: container.photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(container.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: container.photoUrl == null
                    ? const Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: Colors.grey,
                      )
                    : null,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 10,
                  children: [
                    // Texts
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            container.name,
                            style: theme.textTheme.bodyMedium,
                          ),
                          Row(
                            spacing: 5,
                            children: [
                              Row(
                                spacing: 2,
                                children: [
                                  const Icon(
                                    Icons.inventory_2_outlined,
                                    color: Colors.grey,
                                    size: 12,
                                  ),
                                  Text(
                                    "${container.items.length} items",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                spacing: 2,
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.grey,
                                    size: 12,
                                  ),
                                  Text(
                                    container.location.label,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Arrow Icon
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.qr_code_scanner_outlined),
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
