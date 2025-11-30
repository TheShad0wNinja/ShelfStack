import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelfstack/core/viewmodels/theme_viewmodel.dart';

class _ThemeModeInfo {
  final ThemeMode mode;
  final IconData icon;
  final String label;

  _ThemeModeInfo(this.mode, this.icon, this.label);
}

final Map<ThemeMode, _ThemeModeInfo> _themeModeInfo = {
  ThemeMode.system: _ThemeModeInfo(ThemeMode.system, Icons.brightness_auto, "System Default"),
  ThemeMode.light: _ThemeModeInfo(ThemeMode.light, Icons.light_mode, "Light Mode"),
  ThemeMode.dark: _ThemeModeInfo(ThemeMode.dark, Icons.dark_mode, "Dark Mode"),
};

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final currentMode = themeViewModel.themeMode;

    return Row(
      children: [
        SegmentedButton<ThemeMode>(
          showSelectedIcon: false,
          selected: <ThemeMode>{currentMode},

          onSelectionChanged: (Set<ThemeMode> newSelection) {
            if (newSelection.isNotEmpty) {
              context.read<ThemeViewModel>().toggleTheme(newSelection.first);
            }
          },

          segments: ThemeMode.values.map((mode) {
            final info = _themeModeInfo[mode]!;
            return ButtonSegment<ThemeMode>(
              value: mode,
              icon: Icon(info.icon),
              tooltip: info.label,
            );
          }).toList(),

          multiSelectionEnabled: false,
          emptySelectionAllowed: false,
        ),
      ],
    );
  }
}