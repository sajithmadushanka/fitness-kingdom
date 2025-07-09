import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Make sure to add this dependency to your pubspec.yaml

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    // use meterial 3 design
  
    // Define the color scheme with a focus on teal
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal.shade700, // A darker teal for the primary seed
      primary: Colors.teal.shade700,
      onPrimary: Colors.white,
      primaryContainer: Colors.teal.shade100,
      onPrimaryContainer: Colors.teal.shade900,
      secondary: Colors.teal.shade400, // A lighter teal for secondary elements
      onSecondary: Colors.white,
      secondaryContainer: Colors.teal.shade50,
      onSecondaryContainer: Colors.teal.shade800,
      tertiary: Colors.blueGrey.shade700, // A complementary color for tertiary elements
      onTertiary: Colors.white,
      error: Colors.red.shade700,
      onError: Colors.white,
     
      surface: Colors.white, // Surface color for cards, sheets etc.
      onSurface: Colors.black,

      onSurfaceVariant: Colors.grey.shade800,
      outline: Colors.grey.shade400,
      shadow: Colors.black.withValues(alpha: 0.1),
      inverseSurface: Colors.grey.shade900,
      onInverseSurface: Colors.white,
      inversePrimary: Colors.teal.shade200,
      // You can add more color properties here as needed
    ),
    useMaterial3: true, // Enable Material 3 design

    // Define the text theme using Google Fonts
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
      displayMedium: GoogleFonts.poppins(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
      displaySmall: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.teal.shade700),

      headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.teal.shade800),
      headlineMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.teal.shade700),
      headlineSmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.teal.shade600),

      titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.teal.shade700),
      titleMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.teal.shade600),
      titleSmall: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.teal.shade500),

      bodyLarge: GoogleFonts.openSans(fontSize: 16, color: Colors.black87), // Default text size for body
      bodyMedium: GoogleFonts.openSans(fontSize: 14, color: Colors.black87),
      bodySmall: GoogleFonts.openSans(fontSize: 12, color: Colors.black54),

      labelLarge: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white), // For buttons, tabs
      labelMedium: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
      labelSmall: GoogleFonts.openSans(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black54),
    ),

    // Define other common theme properties
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal.shade700,
      foregroundColor: Colors.white,
      elevation: 4,
      titleTextStyle: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.teal.shade400,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
    ),
    buttonTheme: const ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.teal.shade700,
        side: BorderSide(color: Colors.teal.shade700, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.teal.shade700,
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      labelStyle: GoogleFonts.openSans(color: Colors.grey.shade700),
      hintStyle: GoogleFonts.openSans(color: Colors.grey.shade500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: Colors.teal.shade700,
      unselectedLabelColor: Colors.grey.shade600,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: Colors.teal.shade700, width: 3.0),
      ),
      labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
    ),
    // Add more theme properties as needed (e.g., dialogTheme, bottomNavigationBarTheme, etc.)
  );

  static ThemeData darkTheme = ThemeData(
    // Define the color scheme for dark theme with a focus on teal
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal.shade200, // A lighter teal for the primary seed in dark mode
      primary: Colors.teal.shade200,
      onPrimary: Colors.teal.shade900,
      primaryContainer: Colors.teal.shade700,
      onPrimaryContainer: Colors.teal.shade50,
      secondary: Colors.teal.shade500,
      onSecondary: Colors.black,
      secondaryContainer: Colors.teal.shade800,
      onSecondaryContainer: Colors.teal.shade100,
      tertiary: Colors.blueGrey.shade300,
      onTertiary: Colors.blueGrey.shade900,
      error: Colors.red.shade400,
      onError: Colors.black,
      surface: Colors.grey.shade900, // Dark background
      onSurface: Colors.white,
    
      onSurfaceVariant: Colors.white70,
      outline: Colors.grey.shade600,
      shadow: Colors.black.withValues(alpha: 0.5),
      inverseSurface: Colors.grey.shade50,
      onInverseSurface: Colors.black,
      inversePrimary: Colors.teal.shade700,
      brightness: Brightness.dark, // Crucial for dark theme
    ),
    useMaterial3: true, // Enable Material 3 design

    // Define the text theme using Google Fonts for dark mode
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.bold, color: Colors.teal.shade100),
      displayMedium: GoogleFonts.poppins(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.teal.shade200),
      displaySmall: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.teal.shade300),

      headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.teal.shade200),
      headlineMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.teal.shade300),
      headlineSmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.teal.shade400),

      titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.teal.shade300),
      titleMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.teal.shade400),
      titleSmall: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.teal.shade500),

      bodyLarge: GoogleFonts.openSans(fontSize: 16, color: Colors.white70), // Default text size for body
      bodyMedium: GoogleFonts.openSans(fontSize: 14, color: Colors.white60),
      bodySmall: GoogleFonts.openSans(fontSize: 12, color: Colors.white54),

      labelLarge: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black), // For buttons, tabs
      labelMedium: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70),
      labelSmall: GoogleFonts.openSans(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white60),
    ),

    // Define other common theme properties for dark mode
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.white,
      elevation: 4,
      titleTextStyle: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.teal.shade500,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    cardTheme: CardThemeData(
      color: Colors.grey.shade800,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
    ),
    buttonTheme: const ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal.shade500,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.teal.shade200,
        side: BorderSide(color: Colors.teal.shade200, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.teal.shade200,
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade700,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.teal.shade200, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
      ),
      labelStyle: GoogleFonts.openSans(color: Colors.grey.shade300),
      hintStyle: GoogleFonts.openSans(color: Colors.grey.shade400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: Colors.teal.shade200,
      unselectedLabelColor: Colors.grey.shade400,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: Colors.teal.shade200, width: 3.0),
      ),
      labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
    ),
    // Add more theme properties as needed (e.g., dialogTheme, bottomNavigationBarTheme, etc.)
  );
}
