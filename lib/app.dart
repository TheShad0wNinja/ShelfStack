import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/features/inventory/screens/containers_screen.dart';
import 'package:shelfstack/features/home/home_screen.dart';
import 'package:shelfstack/features/map/map_screen.dart';
import 'package:shelfstack/features/search/search_screen.dart';
import 'package:shelfstack/features/settings/settings_screen.dart';
import 'package:shelfstack/core/theme/main_theme.dart';
import 'package:shelfstack/core/widgets/navbar.dart';
import 'package:shelfstack/features/inventory/viewmodels/containers_viewmodel.dart';
import 'package:shelfstack/core/viewmodels/navigation_viewmodel.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final List<Widget> screens = const [
    HomeScreen(),
    ContainersScreen(),
    SearchScreen(),
    MapScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        ChangeNotifierProvider(create: (_) => ContainersViewModel()),
      ],
      child: MaterialApp(
        title: 'ShelfStack',
        home: Consumer<NavigationViewModel>(
          builder: (context, vm, child) => Scaffold(
            body: SafeArea(
              top: true,
              bottom: true,
              child: IndexedStack(index: vm.currentIndex, children: screens),
            ),
            bottomNavigationBar: const NavBar(),
          ),
        ),
        debugShowCheckedModeBanner: false,
        theme: MainTheme.lightThemeData(),
      ),
    );
  }
}
