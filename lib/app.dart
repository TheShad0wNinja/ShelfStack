import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/ui/screens/containers_screen.dart';
import 'package:shelfstack/ui/screens/home_screen.dart';
import 'package:shelfstack/ui/screens/map_screen.dart';
import 'package:shelfstack/ui/screens/search_screen.dart';
import 'package:shelfstack/ui/screens/settings_screen.dart';
import 'package:shelfstack/ui/theme/main_theme.dart';
import 'package:shelfstack/ui/widgets/navbar.dart';
import 'package:shelfstack/viewmodels/containers_viewmodel.dart';
import 'package:shelfstack/viewmodels/navigation_viewmodel.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final List<Widget> screens = const [
    HomeScreen(),
    ContainersScreen(),
    SearchScreen(),
    MapScreen(),
    SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => NavigationViewModel()),
      ChangeNotifierProvider(create: (_) => ContainersViewModel()),
    ],
      child: MaterialApp(
        title: 'ShelfStack',
        home: Consumer<NavigationViewModel>(
          builder: (context, vm, child) =>
            Scaffold(
              body: SafeArea(
                top: true,
                bottom: true,
                child: IndexedStack(index: vm.currentIndex, children: screens),
              ),
              bottomNavigationBar: const NavBar(),
            )
        ),
        debugShowCheckedModeBanner: false,
        theme: MainTheme.lightThemeData(),
      )
    );
  }
}