import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/core/services/deep_link_service.dart';
import 'package:shelfstack/core/theme/theme.dart';
import 'package:shelfstack/core/viewmodels/theme_viewmodel.dart';
import 'package:shelfstack/features/inventory/screens/container_details_screen.dart';
import 'package:shelfstack/features/inventory/screens/containers_screen.dart';
import 'package:shelfstack/features/home/home_screen.dart';
import 'package:shelfstack/features/inventory/viewmodels/container_details_viewmodel.dart';
import 'package:shelfstack/features/map/map_screen.dart';
import 'package:shelfstack/features/qr/qr_scanner_screen.dart';
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
import 'package:shelfstack/features/settings/settings_viewmodel.dart';

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
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, vm, child) {
          return MaterialApp(
            title: 'ShelfStack',
            home: const MainScreen(),
            theme: const MaterialTheme(TextTheme()).light(),
            darkTheme: const MaterialTheme(TextTheme()).dark(),
            themeMode: vm.themeMode,
            debugShowCheckedModeBanner: false,
          );
        },
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
  final DeepLinkService _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    _initializeDeepLinks();
  }

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

  void _initializeDeepLinks() {
    _deepLinkService.onContainerLink = (containerId) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => ContainerDetailsViewModel(),
            child: ContainerDetailsScreen(containerId: containerId),
          ),
        ),
      );
    };

    _deepLinkService.init();
  }

  void _navigateToScanQR() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const QRScannerScreen()));
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
        floatingActionButton: vm.currentIndex < 3
            ? ExpandableFab(
                onCreateContainer: _navigateToCreateContainer,
                onCreateItem: _navigateToCreateItem,
                onScanQR: _navigateToScanQR,
              )
            : null,
      ),
    );
  }
}
