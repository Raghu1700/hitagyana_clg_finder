import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Beautiful Purple Gradient Color Palette (from user's image)
  static const Color tyrianPurple = Color(0xFF45062E); // Deep purple
  static const Color byzantium = Color(0xFF7F055F); // Rich purple-magenta
  static const Color lavenderPink = Color(0xFFE5A4CB); // Soft purple-pink
  static const Color champagnePink = Color(0xFFEBD2BE); // Warm beige-pink
  static const Color almond = Color(0xFFFFE8D4); // Light cream

  // Supporting colors
  static const Color darkGray = Color(0xFF2D1B2E); // Dark purple-gray
  static const Color mediumGray = Color(0xFF6B4C6D); // Medium purple-gray
  static const Color lightGray = Color(0xFFB8A4B8); // Light purple-gray
  static const Color softGray = Color(0xFFF8F3F8); // Very light purple tint
  static const Color pureWhite = Color(0xFFFFFFFF); // Pure white

  // Beautiful Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [tyrianPurple, byzantium],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [byzantium, lavenderPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightGradient = LinearGradient(
    colors: [lavenderPink, champagnePink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [champagnePink, almond],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: byzantium,
      scaffoldBackgroundColor: almond,
      colorScheme: const ColorScheme.light(
        primary: byzantium,
        primaryContainer: lavenderPink,
        secondary: tyrianPurple,
        secondaryContainer: champagnePink,
        tertiary: lavenderPink,
        surface: pureWhite,
        surfaceVariant: softGray,
        background: almond,
        error: Color(0xFFB91372),
        onPrimary: pureWhite,
        onSecondary: pureWhite,
        onSurface: darkGray,
        onSurfaceVariant: mediumGray,
        onBackground: darkGray,
        shadow: Color(0x1A45062E),
        outline: lightGray,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: pureWhite,
        foregroundColor: darkGray,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),
        toolbarTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkGray,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: byzantium,
          foregroundColor: pureWhite,
          elevation: 4,
          shadowColor: byzantium.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: byzantium,
          side: BorderSide(color: byzantium, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: byzantium,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: lightGray.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: byzantium, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFB91372), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.inter(color: lightGray, fontSize: 16),
        labelStyle: GoogleFonts.inter(color: mediumGray, fontSize: 16),
      ),
      cardTheme: CardTheme(
        color: pureWhite,
        elevation: 3,
        shadowColor: tyrianPurple.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: byzantium,
        foregroundColor: pureWhite,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: champagnePink,
        selectedColor: byzantium,
        disabledColor: lightGray.withOpacity(0.3),
        labelStyle: GoogleFonts.inter(
          color: darkGray,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      tabBarTheme: TabBarTheme(
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: byzantium.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: pureWhite,
        unselectedLabelColor: mediumGray,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabAlignment: TabAlignment.fill,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
            fontSize: 32, fontWeight: FontWeight.w800, color: darkGray),
        displayMedium: GoogleFonts.inter(
            fontSize: 28, fontWeight: FontWeight.w700, color: darkGray),
        displaySmall: GoogleFonts.inter(
            fontSize: 24, fontWeight: FontWeight.w600, color: darkGray),
        headlineLarge: GoogleFonts.inter(
            fontSize: 22, fontWeight: FontWeight.w600, color: darkGray),
        headlineMedium: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.w600, color: darkGray),
        headlineSmall: GoogleFonts.inter(
            fontSize: 18, fontWeight: FontWeight.w600, color: darkGray),
        titleLarge: GoogleFonts.inter(
            fontSize: 18, fontWeight: FontWeight.w600, color: darkGray),
        titleMedium: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w600, color: darkGray),
        titleSmall: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w600, color: darkGray),
        bodyLarge: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w400, color: darkGray),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w400, color: mediumGray),
        bodySmall: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w400, color: lightGray),
        labelLarge: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w600, color: darkGray),
        labelMedium: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w600, color: mediumGray),
        labelSmall: GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w600, color: lightGray),
      ),
    );
  }

  // Animation Constants
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Beautiful Shadows with purple tint
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: tyrianPurple.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: tyrianPurple.withOpacity(0.15),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get strongShadow => [
        BoxShadow(
          color: tyrianPurple.withOpacity(0.25),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];

  // Gradient Decorations
  static BoxDecoration get primaryGradientDecoration => BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: byzantium.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static BoxDecoration get accentGradientDecoration => BoxDecoration(
        gradient: accentGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: lavenderPink.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static BoxDecoration get lightGradientDecoration => BoxDecoration(
        gradient: lightGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: champagnePink.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static BoxDecoration get backgroundGradientDecoration => BoxDecoration(
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(20),
      );
}
