import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/repositories/container_repository.dart';

class ContainerSelectionDialog extends StatefulWidget {
  final String? currentContainerId;

  const ContainerSelectionDialog({super.key, this.currentContainerId});

  @override
  State<ContainerSelectionDialog> createState() =>
      _ContainerSelectionDialogState();
}

class _ContainerSelectionDialogState extends State<ContainerSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<models.Container> _containers = [];
  List<models.Container> _filteredContainers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContainers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContainers() async {
    try {
      final repository = context.read<ContainerRepository>();
      final containers = await repository.fetchContainers();
      if (mounted) {
        setState(() {
          _containers = containers;
          _filteredContainers = containers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContainers = _containers.where((c) {
        return c.name.toLowerCase().contains(query) ||
            c.location.label.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Container',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search containers...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (_isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_error != null) {
                    return Center(child: Text('Error: $_error'));
                  }

                  final containers = _filteredContainers
                      .where((c) => c.id != widget.currentContainerId)
                      .toList();

                  if (containers.isEmpty) {
                    return Center(
                      child: Text(
                        'No containers found',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: containers.length,
                    itemBuilder: (context, index) {
                      final container = containers[index];
                      return ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(container.name),
                        subtitle: Text(container.location.label),
                        trailing: Text(
                          '${container.items.length} items',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () => Navigator.of(context).pop(container),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
