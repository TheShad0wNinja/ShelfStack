import 'package:flutter/material.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/item.dart';
import 'package:shelfstack/data/models/location.dart';
import 'package:shelfstack/features/search/widgets/search_result_card.dart';

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
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search Items or containers...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: true,
                        onSelected: (selected) {},
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Containers Only'),
                        selected: false,
                        onSelected: (selected) {},
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Items Only'),
                        selected: false,
                        onSelected: (selected) {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18),
                        const SizedBox(width: 4),
                        Text('Proximity Search', style: textTheme.bodyMedium),
                      ],
                    ),
                    Switch(value: false, onChanged: (value) {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('2 Results Found', style: textTheme.bodySmall),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sort),
                  label: const Text('Sort by Date'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
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
                  const SizedBox(height: 12),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
