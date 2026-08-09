import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// mysihat design tokens aligned with the Finalprototype HTML.
///
/// Soft green wellness UI: ink text, muted secondary, frosted cards,
/// green primary `#168653`. Headings stay expressive (Lora); body uses
/// a clean system-adjacent sans (Raleway) for 40–60 readability.
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF168653);
  static const Color primaryDark = Color(0xFF17683F);
  static const Color accent = Color(0xFF36A978);
  static const Color background = Color(0xFFF5F8F7);
  static const Color foreground = Color(0xFF142238);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF697586);
  static const Color border = Color(0xFFE6ECEA);
  static const Color navHover = Color(0xFFF1F6F3);
  static const Color navActive = Color(0xFFEDF6F0);
  static const Color riskHigh = Color(0xFFE85A54);
  static const Color riskModerate = Color(0xFFE99435);
  static const Color riskLow = Color(0xFF168653);
  static const Color factorPurple = Color(0xFF7771CA);
  static const Color secondaryCompare = Color(0xFF657181);
  static const Color chartFollowPlan = Color(0xFF168653);
  static const Color chartNoChange = Color(0xFFAEB7C0);
  static const Color softGreen = Color(0xFFE3F2E9);
  static const Color softRed = Color(0xFFFFF0EF);
  static const Color softOrange = Color(0xFFFFF6E9);
  static const Color softPurple = Color(0xFFF0EFFD);

  static const double minTapSize = 48;
  static const double minTextSize = 16;
  static const double cardRadius = 22;

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: surface,
        error: riskHigh,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
    );

    final textTheme = GoogleFonts.ralewayTextTheme(base.textTheme)
        .apply(bodyColor: foreground, displayColor: foreground)
        .copyWith(
          bodyLarge: GoogleFonts.raleway(fontSize: 16, height: 1.45, color: foreground, fontWeight: FontWeight.w500),
          bodyMedium: GoogleFonts.raleway(fontSize: 15, height: 1.45, color: foreground),
          bodySmall: GoogleFonts.raleway(fontSize: 13, height: 1.4, color: textSecondary),
          titleLarge: GoogleFonts.raleway(fontSize: 25, fontWeight: FontWeight.w700, letterSpacing: -0.7, color: foreground),
          titleMedium: GoogleFonts.raleway(fontSize: 17, fontWeight: FontWeight.w700, color: foreground),
          titleSmall: GoogleFonts.raleway(fontSize: 15, fontWeight: FontWeight.w700, color: foreground),
          headlineMedium: GoogleFonts.raleway(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -1.2, color: foreground),
          headlineSmall: GoogleFonts.raleway(fontSize: 22, fontWeight: FontWeight.w800, color: foreground),
          labelLarge: GoogleFonts.raleway(fontSize: 14, fontWeight: FontWeight.w700, color: foreground),
        );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.raleway(fontSize: 22, fontWeight: FontWeight.w800, color: foreground),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, minTapSize),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.raleway(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDark,
          minimumSize: const Size(double.infinity, minTapSize),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: Color(0xFF5CA47C)),
          textStyle: GoogleFonts.raleway(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(64, minTapSize),
          textStyle: GoogleFonts.raleway(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDFE7E3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDFE7E3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6BB18F), width: 1.5),
        ),
        labelStyle: GoogleFonts.raleway(fontSize: 13, fontWeight: FontWeight.w700, color: textSecondary),
        hintStyle: GoogleFonts.raleway(fontSize: 14, color: textSecondary),
      ),
      cardTheme: CardThemeData(
        color: surface.withValues(alpha: 0.92),
        elevation: 0,
        shadowColor: const Color(0x0E223948),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: border.withValues(alpha: 0.9)),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: navActive,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? primaryDark : const Color(0xFF344256),
          );
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        side: const BorderSide(color: Color(0xFFC8D3CE), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
      case 'lower':
      case 'low':
      default:
        return factorPurple;
    }
  }

  static Color riskSoft(String? level) {
    switch ((level ?? '').toLowerCase()) {
      case 'high':
        return softRed;
      case 'moderate':
      case 'medium':
        return softOrange;
      default:
        return softPurple;
    }
  }
}
