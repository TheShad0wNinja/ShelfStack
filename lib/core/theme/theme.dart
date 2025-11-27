import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff005dac),
      surfaceTint: Color(0xff005faf),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff1976d2),
      onPrimaryContainer: Color(0xfffffdff),
      secondary: Color(0xff475f84),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffbad3fd),
      onSecondaryContainer: Color(0xff425b7f),
      tertiary: Color(0xff843e9f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff9f58ba),
      onTertiaryContainer: Color(0xfffffeff),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff181c21),
      onSurfaceVariant: Color(0xff414752),
      outline: Color(0xff717783),
      outlineVariant: Color(0xffc1c6d4),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2d3037),
      inversePrimary: Color(0xffa5c8ff),
      primaryFixed: Color(0xffd4e3ff),
      onPrimaryFixed: Color(0xff001c3a),
      primaryFixedDim: Color(0xffa5c8ff),
      onPrimaryFixedVariant: Color(0xff004786),
      secondaryFixed: Color(0xffd4e3ff),
      onSecondaryFixed: Color(0xff001c3a),
      secondaryFixedDim: Color(0xffafc8f1),
      onSecondaryFixedVariant: Color(0xff2f486a),
      tertiaryFixed: Color(0xfff9d8ff),
      onTertiaryFixed: Color(0xff320046),
      tertiaryFixedDim: Color(0xffedb1ff),
      onTertiaryFixedVariant: Color(0xff6b2687),
      surfaceDim: Color(0xffd8dae2),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff2f3fc),
      surfaceContainer: Color(0xffecedf6),
      surfaceContainerHigh: Color(0xffe6e8f0),
      surfaceContainerHighest: Color(0xffe0e2ea),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003669),
      surfaceTint: Color(0xff005faf),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff006ec9),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff1d3759),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff566e93),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff580f74),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff964fb1),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff0e1117),
      onSurfaceVariant: Color(0xff303641),
      outline: Color(0xff4d535e),
      outlineVariant: Color(0xff676d79),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2d3037),
      inversePrimary: Color(0xffa5c8ff),
      primaryFixed: Color(0xff006ec9),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff00559e),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff566e93),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff3d5679),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff964fb1),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff7b3696),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc4c6ce),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff2f3fc),
      surfaceContainer: Color(0xffe6e8f0),
      surfaceContainerHigh: Color(0xffdbdce5),
      surfaceContainerHighest: Color(0xffcfd1d9),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff002c57),
      surfaceTint: Color(0xff005faf),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff004a8a),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff112d4e),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff314a6d),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff4c0067),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff6e2989),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff262c37),
      outlineVariant: Color(0xff434955),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2d3037),
      inversePrimary: Color(0xffa5c8ff),
      primaryFixed: Color(0xff004a8a),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003363),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff314a6d),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff193355),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff6e2989),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff540871),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb6b8c0),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff0f9),
      surfaceContainer: Color(0xffe0e2ea),
      surfaceContainerHigh: Color(0xffd2d4dc),
      surfaceContainerHighest: Color(0xffc4c6ce),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffa5c8ff),
      surfaceTint: Color(0xffa5c8ff),
      onPrimary: Color(0xff00315f),
      primaryContainer: Color(0xff1976d2),
      onPrimaryContainer: Color(0xfffffdff),
      secondary: Color(0xffafc8f1),
      onSecondary: Color(0xff163153),
      secondaryContainer: Color(0xff314a6d),
      onSecondaryContainer: Color(0xffa1bae3),
      tertiary: Color(0xffedb1ff),
      onTertiary: Color(0xff52046e),
      tertiaryContainer: Color(0xff9f58ba),
      onTertiaryContainer: Color(0xfffffeff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff101319),
      onSurface: Color(0xffe0e2ea),
      onSurfaceVariant: Color(0xffc1c6d4),
      outline: Color(0xff8b919e),
      outlineVariant: Color(0xff414752),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe0e2ea),
      inversePrimary: Color(0xff005faf),
      primaryFixed: Color(0xffd4e3ff),
      onPrimaryFixed: Color(0xff001c3a),
      primaryFixedDim: Color(0xffa5c8ff),
      onPrimaryFixedVariant: Color(0xff004786),
      secondaryFixed: Color(0xffd4e3ff),
      onSecondaryFixed: Color(0xff001c3a),
      secondaryFixedDim: Color(0xffafc8f1),
      onSecondaryFixedVariant: Color(0xff2f486a),
      tertiaryFixed: Color(0xfff9d8ff),
      onTertiaryFixed: Color(0xff320046),
      tertiaryFixedDim: Color(0xffedb1ff),
      onTertiaryFixedVariant: Color(0xff6b2687),
      surfaceDim: Color(0xff101319),
      surfaceBright: Color(0xff363940),
      surfaceContainerLowest: Color(0xff0b0e14),
      surfaceContainerLow: Color(0xff181c21),
      surfaceContainer: Color(0xff1c2026),
      surfaceContainerHigh: Color(0xff272a30),
      surfaceContainerHighest: Color(0xff32353b),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffcaddff),
      surfaceTint: Color(0xffa5c8ff),
      onPrimary: Color(0xff00264c),
      primaryContainer: Color(0xff4492f0),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffcaddff),
      onSecondary: Color(0xff082647),
      secondaryContainer: Color(0xff7992b9),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfff6cfff),
      onTertiary: Color(0xff42005a),
      tertiaryContainer: Color(0xffbd74d8),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff101319),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd7dcea),
      outline: Color(0xffacb2bf),
      outlineVariant: Color(0xff8a909d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe0e2ea),
      inversePrimary: Color(0xff004888),
      primaryFixed: Color(0xffd4e3ff),
      onPrimaryFixed: Color(0xff001128),
      primaryFixedDim: Color(0xffa5c8ff),
      onPrimaryFixedVariant: Color(0xff003669),
      secondaryFixed: Color(0xffd4e3ff),
      onSecondaryFixed: Color(0xff001128),
      secondaryFixedDim: Color(0xffafc8f1),
      onSecondaryFixedVariant: Color(0xff1d3759),
      tertiaryFixed: Color(0xfff9d8ff),
      onTertiaryFixed: Color(0xff220031),
      tertiaryFixedDim: Color(0xffedb1ff),
      onTertiaryFixedVariant: Color(0xff580f74),
      surfaceDim: Color(0xff101319),
      surfaceBright: Color(0xff41444b),
      surfaceContainerLowest: Color(0xff05070d),
      surfaceContainerLow: Color(0xff1a1e24),
      surfaceContainer: Color(0xff25282e),
      surfaceContainerHigh: Color(0xff2f3339),
      surfaceContainerHighest: Color(0xff3b3e44),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffeaf0ff),
      surfaceTint: Color(0xffa5c8ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff9fc4ff),
      onPrimaryContainer: Color(0xff000b1e),
      secondary: Color(0xffeaf0ff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffabc4ed),
      onSecondaryContainer: Color(0xff000b1e),
      tertiary: Color(0xfffeeaff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffebacff),
      onTertiaryContainer: Color(0xff190025),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff101319),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeaf0fe),
      outlineVariant: Color(0xffbdc3d0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe0e2ea),
      inversePrimary: Color(0xff004888),
      primaryFixed: Color(0xffd4e3ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffa5c8ff),
      onPrimaryFixedVariant: Color(0xff001128),
      secondaryFixed: Color(0xffd4e3ff),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffafc8f1),
      onSecondaryFixedVariant: Color(0xff001128),
      tertiaryFixed: Color(0xfff9d8ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffedb1ff),
      onTertiaryFixedVariant: Color(0xff220031),
      surfaceDim: Color(0xff101319),
      surfaceBright: Color(0xff4d5057),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1c2026),
      surfaceContainer: Color(0xff2d3037),
      surfaceContainerHigh: Color(0xff383b42),
      surfaceContainerHighest: Color(0xff44474d),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,

    appBarTheme: AppBarThemeData(
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface
    ),
  );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
