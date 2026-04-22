import 'package:flutter/material.dart';

import '../../core/constants.dart';

class AppTheme {
  static ThemeData dark() {
    const primary = Color(AppColors.primary);
    const background = Color(AppColors.background);
    const surface = Color(AppColors.surface);
    const surfaceVariant = Color(AppColors.surfaceVariant);
    const inactive = Color(AppColors.onSurfaceVariant);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primary,
        surface: surface,
        onPrimary: Colors.black,
        onSurface: Colors.white,
      ),
      cardColor: surfaceVariant,
      dividerColor: inactive,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: inactive,
        type: BottomNavigationBarType.fixed,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: inactive,
        thumbColor: primary,
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.white),
        headlineMedium: TextStyle(color: Colors.white),
        headlineSmall: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        bodySmall: TextStyle(color: Colors.white54),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData light() {
    const primary = Color(AppColors.primary);
    const background = Color(0xFFF8F8F8);
    const onBackground = Color(0xFF333333);
    const bodySecondary = Color(0xFF666666);
    const inactive = Color(0xFF999999);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: primary,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSurface: onBackground,
      ),
      cardColor: Colors.white,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerColor: inactive,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: onBackground,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: onBackground,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: onBackground),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: inactive,
        type: BottomNavigationBarType.fixed,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: inactive,
        thumbColor: primary,
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: onBackground),
        headlineMedium: TextStyle(color: onBackground),
        headlineSmall: TextStyle(color: onBackground),
        titleLarge: TextStyle(color: onBackground),
        titleMedium: TextStyle(color: onBackground),
        titleSmall: TextStyle(color: onBackground),
        bodyLarge: TextStyle(color: onBackground),
        bodyMedium: TextStyle(color: bodySecondary),
        bodySmall: TextStyle(color: bodySecondary),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
