import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const primary = Color(0xFF3B6CF8);
  static const primaryDark = Color(0xFF2451D6);
  static const secondary = Color(0xFF00D4AA);
  static const background = Color(0xFFF5F7FF);
  static const surface = Color(0xFFFFFFFF);
  static const error = Color(0xFFFF5252);
  static const warning = Color(0xFFFFB74D);
  static const success = Color(0xFF4CAF50);
  static const textPrimary = Color(0xFF1A1D3B);
  static const textSecondary = Color(0xFF6B7280);

  // Pill Colors (for medicine cards)
  static const pillColors = [
    Color(0xFFFF6B6B), // coral red
    Color(0xFF4D96FF), // sky blue
    Color(0xFF6BCB77), // mint green
    Color(0xFFFFD93D), // sunny yellow
    Color(0xFFC77DFF), // lavender
    Color(0xFFFF9A3C), // tangerine
    Color(0xFF00C9A7), // teal
    Color(0xFFFF6FB8), // rose pink
  ];

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Nunito',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          background: background,
          surface: surface,
          primary: primary,
          secondary: secondary,
          error: error,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: const TextStyle(color: textSecondary, fontFamily: 'Nunito'),
        ),
      );
}

class AppStrings {
  static const appName = 'MedBuddy';
  static const today = 'Today';
  static const medicines = 'My Medicines';
  static const history = 'History';
  static const addMedicine = 'Add Medicine';
  static const scanPrescription = 'Scan Prescription';
  static const markTaken = 'Mark as Taken';
  static const skip = 'Skip';
  static const noMedicines = 'No medicines yet';
  static const addFirst = 'Tap + to add your first medicine';
}
