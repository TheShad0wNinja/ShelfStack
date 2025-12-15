import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';
import 'package:shelfstack/features/inventory/viewmodels/containers_viewmodel.dart';
import 'package:shelfstack/features/inventory/widgets/container_row.dart';

class ContainersView extends StatelessWidget {
  const ContainersView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContainersViewModel>(
      create: (context) => ContainersViewModel(
        context.read<ContainerRepository>(),
        context.read<ItemRepository>(),
      ),
      child: _ContainerViewContent(),
    );
  }
}

class _ContainerViewContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ContainerViewContentState();
}

class _ContainerViewContentState extends State<_ContainerViewContent> {
  final TextEditingController _searchController = TextEditingController();

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChange);
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  void _onSearchChange() {
    final query = _searchController.text;
    context.read<ContainersViewModel>().updateQuery(query);
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _toggleSearch,
              )
            : null,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Search Containers...",
                  border: InputBorder.none,
                ),
              )
            : Text('Containers', style: Theme.of(context).textTheme.headlineSmall),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _toggleSearch,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Consumer<ContainersViewModel>(
          builder: (context, vm, child) => ListView.separated(
            itemCount: vm.containers.length,
            itemBuilder: (context, index) =>
                ContainerRow(container: vm.containers[index]),
            separatorBuilder: (context, index) => const Divider(),
          ),
        ),
      ),
    );
  }
}
