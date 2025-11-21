import 'package:flutter/material.dart';
import 'package:shelfstack/ui/screens/container_details_screen.dart';

class ActivityRow extends StatelessWidget {
  final String? photoUrl;
  final String title;
  final int itemCount;
  final String location;
  final String? containerId;

  const ActivityRow({
    super.key,
    this.photoUrl,
    required this.title,
    required this.itemCount,
    required this.location,
    this.containerId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
      child: InkWell(
        onTap: containerId != null
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ContainerDetailsScreen(containerId: containerId!),
                  ),
                );
              }
            : null,
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
                  image: photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: photoUrl == null
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
                          Text(title, style: theme.textTheme.bodyMedium),
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
                                    "$itemCount items",
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
                                    location,
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
