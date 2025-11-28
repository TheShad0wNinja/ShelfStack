import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/core/theme/theme.dart';
import 'package:shelfstack/features/inventory/screens/containers_screen.dart';
import 'package:shelfstack/features/home/home_screen.dart';
import 'package:shelfstack/features/map/map_screen.dart';
import 'package:shelfstack/features/search/search_screen.dart';
import 'package:shelfstack/features/settings/settings_screen.dart';

import 'package:shelfstack/core/widgets/navbar.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/database/container_repository_sqlite.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';
import 'package:shelfstack/data/database/item_repository_sqlite.dart';
import 'package:shelfstack/core/viewmodels/navigation_viewmodel.dart';
import 'package:shelfstack/features/inventory/widgets/expandable_fab.dart';
import 'package:shelfstack/features/inventory/screens/create_container_screen.dart';
import 'package:shelfstack/features/inventory/screens/add_item_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        Provider<ContainerRepository>(
          create: (_) => ContainerRepositorySqlite(),
        ),
        Provider<ItemRepository>(create: (_) => ItemRepositorySqlite()),
      ],
      child: MaterialApp(
        title: 'ShelfStack',
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
        theme: const MaterialTheme(TextTheme()).light(),
        darkTheme: const MaterialTheme(TextTheme()).dark(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> screens = const [
    HomeScreen(),
    ContainersScreen(),
    SearchScreen(),
    MapScreen(),
    SettingsScreen(),
  ];

  void _navigateToCreateContainer() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateContainerScreen()),
    );
  }

  void _navigateToCreateItem() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddItemScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationViewModel>(
      builder: (context, vm, child) => Scaffold(
        extendBody: true,
        body: SafeArea(
          top: true,
          bottom: false,
          child: IndexedStack(index: vm.currentIndex, children: screens),
        ),
        bottomNavigationBar: const NavBar(),
        floatingActionButton: ExpandableFab(
          onCreateContainer: _navigateToCreateContainer,
          onCreateItem: _navigateToCreateItem,
        ),
      ),
    );
  }
}
