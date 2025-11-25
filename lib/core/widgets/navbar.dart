import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/core/viewmodels/navigation_viewmodel.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Consumer<NavigationViewModel>(
          builder: (context, vm, child) => NavigationBar(
            backgroundColor: Colors.white.withAlpha(
              200,
            ),
            elevation: 0,
            selectedIndex: vm.currentIndex,
            onDestinationSelected: (int index) => vm.setIndex(index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, size: 30),
                selectedIcon: Icon(Icons.home_sharp, size: 30),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory),
                label: 'Containers',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined, size: 30),
                selectedIcon: Icon(Icons.search, size: 30),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map_sharp),
                label: 'Map',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Setting',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
