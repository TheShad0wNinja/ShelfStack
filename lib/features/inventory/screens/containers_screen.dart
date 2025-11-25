import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/core/widgets/rounded_appbar.dart';
import 'package:shelfstack/core/widgets/search_field.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/features/inventory/viewmodels/containers_screen_viewmodel.dart';
import 'package:shelfstack/features/inventory/widgets/container_row.dart';

class ContainersScreen extends StatelessWidget {
  const ContainersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContainersScreenViewModel>(
      create: (context) =>
          ContainersScreenViewModel(context.read<ContainerRepository>()),
      child: _ContainerScreenContent(),
    );
  }
}

class _ContainerScreenContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ContainerScreenContentState();
}

class _ContainerScreenContentState extends State<_ContainerScreenContent> {
  final TextEditingController _searchController = TextEditingController();

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
    context.read<ContainersScreenViewModel>().updateQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RoundedAppBar(
        height: 72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchField(
              hintText: "Search Containers...",
              controller: _searchController,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 10),
        child: Consumer<ContainersScreenViewModel>(
          builder: (context, vm, child) => ListView.separated(
            itemCount: vm.containers.length,
            itemBuilder: (context, index) =>
                ContainerRow(container: vm.containers[index]),
            separatorBuilder: (context, index) => SizedBox(height: 5),
          ),
        ),
      ),
    );
  }
}
