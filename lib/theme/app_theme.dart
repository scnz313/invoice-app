import 'package:flutter/material.dart';

class AppTheme {
  // Airbnb-inspired color palette
  static const Color rausch = Color(0xFFFF5A5F); // Primary red
  static const Color babu = Color(0xFF00A699); // Primary teal
  static const Color arches = Color(0xFFFC642D); // Orange
  static const Color hof = Color(0xFF484848); // Dark gray
  static const Color foggy = Color(0xFF767676); // Medium gray
  static const Color hofLight = Color(0xFF767676); // Light gray
  static const Color snow = Color(0xFFFFFFFF); // White
  static const Color ghost = Color(0xFFF7F7F7); // Light background
  static const Color darkSnow = Color(0xFF1A1A1A); // Dark mode background
  static const Color darkGhost = Color(0xFF2D2D2D); // Dark mode card background

  // Typography
  static const String fontFamily = 'Roboto';

  // Text styles
  static const TextStyle headline1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: hof,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: hof,
  );

  static const TextStyle headline3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: hof,
  );

  static const TextStyle headline4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    color: hof,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: hof,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: foggy,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: foggy,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: snow,
  );

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: const ColorScheme.light(
        primary: rausch,
        secondary: babu,
        tertiary: arches,
        surface: snow,
        background: ghost,
        error: rausch,
        onPrimary: snow,
        onSecondary: snow,
        onTertiary: snow,
        onSurface: hof,
        onBackground: hof,
        onError: snow,
      ),
      scaffoldBackgroundColor: ghost,
      appBarTheme: const AppBarTheme(
        backgroundColor: snow,
        foregroundColor: hof,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headline4,
        iconTheme: IconThemeData(color: hof),
      ),
      cardTheme: CardTheme(
        color: snow,
        elevation: 2,
        shadowColor: hof.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: rausch,
          foregroundColor: snow,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: rausch,
          side: const BorderSide(color: rausch, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: button.copyWith(color: rausch),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: rausch,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: body1.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: snow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: foggy.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: rausch, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: rausch, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: body2.copyWith(color: foggy),
        labelStyle: body2.copyWith(color: foggy),
      ),
      textTheme: const TextTheme(
        headlineLarge: headline1,
        headlineMedium: headline2,
        headlineSmall: headline3,
        titleLarge: headline4,
        bodyLarge: body1,
        bodyMedium: body2,
        bodySmall: caption,
        labelLarge: button,
      ),
      iconTheme: const IconThemeData(
        color: hof,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: foggy,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: snow,
        selectedColor: rausch.withOpacity(0.1),
        labelStyle: body2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(color: foggy.withOpacity(0.2)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: snow,
        selectedItemColor: rausch,
        unselectedItemColor: foggy,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: rausch,
        foregroundColor: snow,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: rausch,
        secondary: babu,
        tertiary: arches,
        surface: darkGhost,
        background: darkSnow,
        error: rausch,
        onPrimary: snow,
        onSecondary: snow,
        onTertiary: snow,
        onSurface: snow,
        onBackground: snow,
        onError: snow,
      ),
      scaffoldBackgroundColor: darkSnow,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkGhost,
        foregroundColor: snow,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headline4,
        iconTheme: IconThemeData(color: snow),
      ),
      cardTheme: CardTheme(
        color: darkGhost,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: rausch,
          foregroundColor: snow,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: rausch,
          side: const BorderSide(color: rausch, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: button.copyWith(color: rausch),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: rausch,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: body1.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkGhost,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: foggy.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: rausch, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: rausch, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: body2.copyWith(color: foggy),
        labelStyle: body2.copyWith(color: foggy),
      ),
      textTheme: const TextTheme(
        headlineLarge: headline1,
        headlineMedium: headline2,
        headlineSmall: headline3,
        titleLarge: headline4,
        bodyLarge: body1,
        bodyMedium: body2,
        bodySmall: caption,
        labelLarge: button,
      ),
      iconTheme: const IconThemeData(
        color: snow,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: foggy,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkGhost,
        selectedColor: rausch.withOpacity(0.2),
        labelStyle: body2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(color: foggy.withOpacity(0.3)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkGhost,
        selectedItemColor: rausch,
        unselectedItemColor: foggy,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: rausch,
        foregroundColor: snow,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }

  // Custom styles
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: snow,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: hof.withOpacity(0.08),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get darkCardDecoration => BoxDecoration(
    color: darkGhost,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get gradientDecoration => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [rausch, babu],
    ),
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // Border radius
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;
} 