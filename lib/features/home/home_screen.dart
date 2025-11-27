import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';
import 'package:shelfstack/features/home/home_screen_view_model.dart';
import 'package:shelfstack/features/inventory/screens/create_container_screen.dart';
import 'package:shelfstack/features/home/widgets/activity_row.dart';
import 'package:shelfstack/data/models/container.dart' as models;
import 'package:shelfstack/data/models/location.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMMM d').format(DateTime.now());
    final theme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (BuildContext context) => HomeScreenViewModel(
        context.read<ContainerRepository>(),
        context.read<ItemRepository>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Good Evening, Mohey", style: theme.textTheme.titleMedium),
                Text(
                  formattedDate,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.only(bottom: 100),
        //   child: FloatingActionButton.extended(
        //     onPressed: () {
        //       Navigator.of(context).push(
        //         MaterialPageRoute(
        //           builder: (context) => const CreateContainerScreen(),
        //         ),
        //       );
        //     },
        //     icon: const Icon(Icons.add),
        //     label: const Text('Create Container'),
        //   ),
        // ),
        body: Consumer<HomeScreenViewModel>(
          builder: (context, vm, child) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 100),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.inventory_2_outlined,
                          label: "Total Containers",
                          value: vm.totalContainers,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.list_alt_outlined,
                          label: "Total Items",
                          value: vm.totalItems,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Recent Activities",
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 10),
                  vm.isLoadingContainers
                      ? Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: const CircularProgressIndicator(),
                        )
                      : ListView.separated(
                          itemBuilder: (context, index) => ActivityRow(
                            container: vm.recentContainers[index],
                          ),
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(height: 20),
                          itemCount: vm.recentContainers.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int value,
    required Color color,
    bool isLoading = false,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(icon, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Text(label, style: textTheme.bodySmall),
            if (isLoading) const SizedBox(height: 8),
            isLoading
                ? SizedBox(
                    height: textTheme.titleLarge?.fontSize,
                    width: textTheme.titleLarge?.fontSize,
                    child: const CircularProgressIndicator(),
                  )
                : Text(
                    value.toString(),
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
