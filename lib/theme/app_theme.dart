import 'package:flutter/material.dart';

class AppTheme {
  // Airbnb-style color palette
  static const Color rausch = Color(0xFFFF5A5F); // Airbnb red
  static const Color babu = Color(0xFF00A699);   // Airbnb green
  static const Color hof = Color(0xFF484848);    // Airbnb dark gray
  static const Color foggy = Color(0xFFB0B0B0);  // Airbnb light gray
  static const Color snow = Color(0xFFFFFFFF);   // White
  static const Color ghost = Color(0xFFF7F7F7);  // Airbnb background

  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;

  // Border radius
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius14 = 14.0;
  static const double radius16 = 16.0;
  static const double radius24 = 24.0;

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Default values
  static const double defaultTaxRate = 18.0;
  static const List<String> paymentMethods = ['Cash', 'Card', 'UPI', 'Bank Transfer', 'Cheque'];

  // Gradient decoration for logo/icon
  static const BoxDecoration gradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [rausch, babu],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.all(Radius.circular(24)),
  );

  // Text styles
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: hof,
  );
  static const TextStyle headline4 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: hof,
  );
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: hof,
  );
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: hof,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: foggy,
  );
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: snow,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: hof,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: hof,
  );

  // Color aliases for compatibility
  static const Color primaryColor = rausch;
  static const Color backgroundColor = ghost;
  static const Color textSecondary = foggy;

  // Theme data
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.red,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: snow,
      textTheme: const TextTheme(
        headlineLarge: headline1,
        headlineMedium: headline2,
        headlineSmall: headline3,
        titleLarge: headline4,
        bodyLarge: body1,
        bodyMedium: body2,
        bodySmall: caption,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: snow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius12),
          ),
        ),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius12),
        ),
        elevation: 2,
      ),
      useMaterial3: true,
    );
  }
} 