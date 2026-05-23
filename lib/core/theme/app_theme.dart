import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Builds ThemeData for both dark and light modes.
/// Accent color is parameterized for dynamic theming.
class AppTheme {
  AppTheme._();

  static ThemeData dark({Color accent = AppColors.defaultAccent}) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      canvasColor: AppColors.darkBackgroundSecondary,
      cardColor: AppColors.darkBackgroundSecondary,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: AppColors.darkBackgroundSecondary,
        error: AppColors.destructive,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      dividerColor: AppColors.darkBorderSubtle,
      splashFactory: InkSparkle.splashFactory,
      useMaterial3: true,
    );
  }

  static ThemeData light({Color accent = AppColors.defaultAccentLight}) {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      canvasColor: AppColors.lightBackgroundSecondary,
      cardColor: AppColors.lightBackgroundSecondary,
      colorScheme: ColorScheme.light(
        primary: accent,
        secondary: accent,
        surface: AppColors.lightBackgroundSecondary,
        error: AppColors.destructiveLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.light().textTheme,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      dividerColor: AppColors.lightBorderSubtle,
      splashFactory: InkSparkle.splashFactory,
      useMaterial3: true,
    );
  }
}
