import 'package:flutter/material.dart';

class MainTheme {
  static ThemeData lightThemeData() {
    const primaryColor = Color(0xFF1976D2);
    const secondaryColor = Color(0xFFFFA000);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      // primary: primaryColor,
      // secondary: secondaryColor,
      // surface: Colors.orange,
      // surfaceTint: Colors.purple,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // // AppBar Theme
      // appBarTheme: AppBarTheme(
      //   backgroundColor: colorScheme.surface,
      //   foregroundColor: colorScheme.onSurface,
      //   elevation: 0,
      //   scrolledUnderElevation: 2,
      //   centerTitle: true,
      //   titleTextStyle: TextStyle(
      //     color: colorScheme.onSurface,
      //     fontSize: 20,
      //     fontWeight: FontWeight.w600,
      //   ),
      // ),
      //
      // // Card Theme
      // cardTheme: CardThemeData(
      //   elevation: 0,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(12),
      //     side: BorderSide(color: colorScheme.outlineVariant.withAlpha(80)),
      //   ),
      //   color: Colors.white,
      //   margin: EdgeInsets.zero,
      // ),
      //
      // // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
      //   filled: true,
      //   fillColor: Colors.white,
      //   contentPadding: const EdgeInsets.symmetric(
      //     horizontal: 16,
      //     vertical: 14,
      //   ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
      //   enabledBorder: OutlineInputBorer(
      //     borderRadius: BorderRadius.circular(12),
      //     borderSide: BorderSide(color: colorScheme.outlineVariant),
      //   ),
      //   focusedBorder: OutlineInputBorder(
      //     borderRadius: BorderRadius.circular(12),
      //     borderSide: BorderSide(color: primaryColor, width: 2),
      //   ),
      //   errorBorder: OutlineInputBorder(
      //     borderRadius: BorderRadius.circular(12),
      //     borderSide: BorderSide(color: colorScheme.error),
      //   ),
      ),
      //
      // // Button Themes
      // elevatedButtonTheme: ElevatedButtonThemeData(
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: primaryColor,
      //     foregroundColor: Colors.white,
      //     elevation: 0,
      //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(12),
      //     ),
      //     textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      //   ),
      // ),
      //
      // outlinedButtonTheme: OutlinedButtonThemeData(
      //   style: OutlinedButton.styleFrom(
      //     foregroundColor: primaryColor,
      //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(12),
      //     ),
      //     side: BorderSide(color: primaryColor),
      //     textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      //   ),
      // ),
      //
      // // Navigation Bar Theme
      // navigationBarTheme: NavigationBarThemeData(
      //   backgroundColor: Colors.white,
      //   elevation: 2,
      //   indicatorColor: primaryColor.withAlpha(90),
      //   labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      // ),
      //
      // floatingActionButtonTheme: FloatingActionButtonThemeData(
      //   backgroundColor: primaryColor,
      //   foregroundColor: Colors.white,
      //   elevation: 2,
      //
      // )
    );
  }
}
