import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/core/services/deep_link_service.dart';
import 'package:shelfstack/core/theme/theme.dart';
import 'package:shelfstack/core/viewmodels/theme_viewmodel.dart';
import 'package:shelfstack/features/inventory/views/container_details_view.dart';
import 'package:shelfstack/features/inventory/views/containers_view.dart';
import 'package:shelfstack/features/home/home_view.dart';
import 'package:shelfstack/features/inventory/viewmodels/container_details_viewmodel.dart';
import 'package:shelfstack/features/map/views/map_view.dart';
import 'package:shelfstack/features/qr/qr_scanner_view.dart';
import 'package:shelfstack/features/search/search_view.dart';
import 'package:shelfstack/features/settings/settings_view.dart';

import 'package:shelfstack/core/widgets/navbar.dart';
import 'package:shelfstack/data/repositories/container_repository.dart';
import 'package:shelfstack/data/database/container_repository_sqlite.dart';
import 'package:shelfstack/data/repositories/item_repository.dart';
import 'package:shelfstack/data/database/item_repository_sqlite.dart';
import 'package:shelfstack/core/viewmodels/navigation_viewmodel.dart';
import 'package:shelfstack/features/inventory/widgets/expandable_fab.dart';
import 'package:shelfstack/features/inventory/views/create_container_view.dart';
import 'package:shelfstack/features/inventory/views/add_item_view.dart';
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
            home: const MainView(),
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

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final List<Widget> views = const [
    HomeView(),
    ContainersView(),
    SearchView(),
    MapView(),
    SettingsView(),
  ];
  final DeepLinkService _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    _initializeDeepLinks();
  }

  void _navigateToCreateContainer() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateContainerView()),
    );
  }

  void _navigateToCreateItem() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddItemView()));
  }

  void _initializeDeepLinks() {
    _deepLinkService.onContainerLink = (containerId) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ContainerDetailsView(containerId: containerId),
        ),
      );
    };

    _deepLinkService.init();
  }

  void _navigateToScanQR() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const QRScannerView()));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationViewModel>(
      builder: (context, vm, child) => Scaffold(
        extendBody: true,
        body: SafeArea(
          top: true,
          bottom: false,
          child: IndexedStack(index: vm.currentIndex, children: views),
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
