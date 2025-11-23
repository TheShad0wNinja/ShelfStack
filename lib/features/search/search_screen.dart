import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/models/location.dart';
import 'package:shelfstack/features/search/widgets/search_result_card.dart';
import 'package:shelfstack/core/widgets/rounded_appbar.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SearchScreenContent();
  }
}

class _SearchScreenContent extends StatefulWidget {
  const _SearchScreenContent();

  @override
  State<_SearchScreenContent> createState() => _SearchScreenContentState();
}

class _SearchScreenContentState extends State<_SearchScreenContent> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: RoundedAppBar(
        height: 214,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search Items or containers...',
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              spacing: 4,
              children: [
                const Icon(Icons.filter_list, size: 18),
                Text('Filters', style: textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              spacing: 10,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: true,
                  onSelected: (selected) {},
                ),
                ChoiceChip(
                  label: const Text('Containers Only'),
                  selected: false,
                  onSelected: (selected) {},
                ),
                ChoiceChip(
                  label: const Text('Items Only'),
                  selected: false,
                  onSelected: (selected) {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 2,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18),
                    Text('Proximity Search', style: textTheme.bodyMedium),
                  ],
                ),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: false,
                    onChanged: (value) {},
                    inactiveThumbColor: Colors.grey.shade400,
                    inactiveTrackColor: Colors.transparent,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('2 Results Found', style: textTheme.bodySmall),
                Row(
                  children: [
                    Text(
                      'Sort by: ',
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Date',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  Column(
                    children: [
                      SearchResultCard.container(
                        container: models.Container(
                          id: 'static-1',
                          name: 'Static Container',
                          tags: ['static'],
                          location: Location(
                            latitude: 0,
                            longitude: 0,
                            label: 'Static Location',
                            address: '123 Static St',
                          ),
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                          items: [],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      SearchResultCard.item(
                        item: Item(
                          id: 'static-item-1',
                          name: 'Static Item',
                          containerId: 'static-1',
                          tags: ['static'],
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                        containerName: 'Static Container',
                        containerId: 'static-1',
                        containerLocation: 'Static Location',
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
