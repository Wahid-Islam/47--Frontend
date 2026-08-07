import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// mysihat "Green/white wellness" design tokens and [ThemeData].
///
/// Headings use Lora (serif, warm), body copy uses Raleway (clean,
/// legible sans-serif). Minimum body text is 16px and minimum tap target
/// is 48px per the product's accessibility bar (users aged 40-60+).
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF1B7A4E);
  static const Color accent = Color(0xFF059669);
  static const Color background = Color(0xFFF7FBF8);
  static const Color foreground = Color(0xFF14532D);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF4B6357);
  static const Color border = Color(0xFFD8EFE1);
  static const Color riskHigh = Color(0xFFDC2626);
  static const Color riskModerate = Color(0xFFD97706);
  static const Color riskLow = Color(0xFF059669);
  static const Color secondaryCompare = Color(0xFF7C7C86);
  static const Color chartFollowPlan = Color(0xFF059669);
  static const Color chartNoChange = Color(0xFF7C3AED);

  static const double minTapSize = 48;
  static const double minTextSize = 16;

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: surface,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
    );

    final textTheme = GoogleFonts.ralewayTextTheme(base.textTheme)
        .apply(bodyColor: foreground, displayColor: foreground)
        .copyWith(
          bodyLarge: GoogleFonts.raleway(fontSize: 17, height: 1.4, color: foreground),
          bodyMedium: GoogleFonts.raleway(fontSize: 16, height: 1.4, color: foreground),
          bodySmall: GoogleFonts.raleway(fontSize: 16, height: 1.35, color: textSecondary),
          titleLarge: GoogleFonts.raleway(fontSize: 24, fontWeight: FontWeight.w700, color: foreground),
          titleMedium: GoogleFonts.raleway(fontSize: 20, fontWeight: FontWeight.w600, color: foreground),
          titleSmall: GoogleFonts.raleway(fontSize: 18, fontWeight: FontWeight.w600, color: foreground),
          headlineMedium: GoogleFonts.lora(fontSize: 32, fontWeight: FontWeight.w700, color: foreground),
          headlineSmall: GoogleFonts.lora(fontSize: 26, fontWeight: FontWeight.w700, color: foreground),
          labelLarge: GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.w600, color: foreground),
        );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.w700, color: foreground),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, minTapSize),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.raleway(fontSize: 17, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, minTapSize),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: primary, width: 1.5),
          textStyle: GoogleFonts.raleway(fontSize: 17, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(64, minTapSize),
          textStyle: GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: GoogleFonts.raleway(fontSize: 16, color: textSecondary),
        hintStyle: GoogleFonts.raleway(fontSize: 16, color: textSecondary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accent.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? primary : textSecondary,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: accent.withValues(alpha: 0.16),
        selectedIconTheme: const IconThemeData(color: primary),
        unselectedIconTheme: const IconThemeData(color: textSecondary),
        selectedLabelTextStyle: const TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelTextStyle: const TextStyle(color: textSecondary, fontSize: 13),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.grey.shade400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent.withValues(alpha: 0.45);
          return Colors.grey.shade300;
        }),
      ),
    );
  }

  static Color riskColor(String? level) {
    switch ((level ?? '').toLowerCase()) {
      case 'high':
        return riskHigh;
      case 'moderate':
      case 'medium':
        return riskModerate;
      default:
        return riskLow;
    }
  }
}
