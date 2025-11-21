import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/features/inventory/screens/create_container_screen.dart';
import 'package:shelfstack/features/home/widgets/activity_row.dart';
import 'package:shelfstack/features/inventory/viewmodels/containers_viewmodel.dart';

import 'package:shelfstack/core/widgets/rounded_appbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMMM d').format(DateTime.now());

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: RoundedAppBar(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Good Evening, Mohey", style: textTheme.titleMedium),
            Text(
              formattedDate,
              style: textTheme.titleSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CreateContainerScreen(),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Create Container'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 100),
          child: Column(
            spacing: 20,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 15,
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          spacing: 4,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              "Total Containers",
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Consumer<ContainersViewModel>(
                              builder: (context, vm, child) {
                                return Text(
                                  "${vm.totalContainers}",
                                  style: textTheme.titleMedium?.copyWith(
                                    height: 1.1,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          spacing: 4,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.list_alt_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              "Total Items",
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Consumer<ContainersViewModel>(
                              builder: (context, vm, child) {
                                return Text(
                                  "${vm.totalItems}",
                                  style: textTheme.titleMedium?.copyWith(
                                    height: 1.1,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                spacing: 6,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Quick Actions", style: textTheme.titleSmall),
                  const SizedBox(height: 10),
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: Material(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                          elevation: 1,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.qr_code_outlined,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Scan QR",
                                    style: textTheme.labelMedium?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Material(
                          color: theme.colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(8),
                          elevation: 1,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_circle_outline,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Add Item",
                                    style: textTheme.labelMedium?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Material(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                          elevation: 1,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.search,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Search All",
                                    style: textTheme.labelMedium?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                spacing: 6,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Recent Activities", style: textTheme.titleSmall),
                  const SizedBox(height: 10),
                  Consumer<ContainersViewModel>(
                    builder: (context, vm, child) {
                      if (vm.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final recentContainers = vm.recentContainers;

                      if (recentContainers.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'No recent activity',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: recentContainers.length > 5
                            ? 5
                            : recentContainers.length,
                        itemBuilder: (context, index) {
                          final container = recentContainers[index];
                          return Column(
                            children: [
                              ActivityRow(container: container),
                              if (index != recentContainers.length - 1)
                                const SizedBox(height: 10),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
