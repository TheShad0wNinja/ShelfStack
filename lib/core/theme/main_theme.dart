import 'package:flutter/material.dart';

class MainTheme {
  static ThemeData lightThemeData() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: const Color(0xff1976D2),
      onPrimary: Colors.white,
      secondary: Colors.orange,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      surface: const Color(0xfff5f7fa),
      onSurface: Colors.black,
      tertiary: Colors.cyan,
      onTertiary: Colors.white,
    );

    return ThemeData(
      colorScheme: colorScheme,

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: colorScheme.primary.withAlpha(0),
        indicatorShape: const StadiumBorder(),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: colorScheme.primary);
          }
          return TextStyle(color: colorScheme.onSurfaceVariant);
        }),
      ),

      extensions: [],
    );
  }
}
