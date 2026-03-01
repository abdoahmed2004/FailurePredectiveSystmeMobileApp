import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Semantic color tokens via ColorScheme
//
//  Mapping used throughout the app:
//    cs.surface              → page / card / nav backgrounds (white ↔ #1E1E1E)
//    cs.onSurface            → primary text (#1A1A1A ↔ white)
//    cs.onSurfaceVariant     → secondary/hint text (#888888 ↔ #AAAAAA)
//    cs.outline              → borders / dividers (#EEEEEE ↔ #2A2A2A)
//    cs.surfaceContainerHighest → input / dropdown fill (#F8F8F8 ↔ #2A2A2A)
//    cs.primary              → brand purple #5C3A9E (fixed both modes)
//    cs.onPrimary            → white text on purple (fixed)
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  // ── Brand purple ─────────────────────────────────────────────────────────
  static const _purple = Color(0xFF5C3A9E);

  // ── Light ─────────────────────────────────────────────────────────────────
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: _purple,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: const Color(0xFF1A1A1A),
          onSurfaceVariant: const Color(0xFF888888),
          outline: const Color(0xFFEEEEEE),
          surfaceContainerHighest: const Color(0xFFF8F8F8),
          surfaceContainer: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
        cardColor: Colors.white,
        dividerColor: const Color(0xFFEEEEEE),
      );

  // ── Dark ──────────────────────────────────────────────────────────────────
  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: _purple,
          onPrimary: Colors.white,
          surface: const Color(0xFF1E1E1E),
          onSurface: const Color(0xFFFFFFFF),
          onSurfaceVariant: const Color(0xFFAAAAAA),
          outline: const Color(0xFF2A2A2A),
          surfaceContainerHighest: const Color(0xFF2A2A2A),
          surfaceContainer: const Color(0xFF121212),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        cardColor: const Color(0xFF1E1E1E),
        dividerColor: const Color(0xFF2A2A2A),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Convenience extension — use context.cs anywhere you have BuildContext
// ─────────────────────────────────────────────────────────────────────────────
extension AppThemeX on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
