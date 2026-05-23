import 'package:flutter/material.dart';

/// Complete color system for Neatly app.
/// Dark mode is the PRIMARY mode — designed dark first, light second.
class AppColors {
  AppColors._();

  // ─── DARK MODE ───
  static const darkBackground = Color(0xFF0A0A0F);
  static const darkBackgroundSecondary = Color(0xFF111118);
  static const darkBackgroundTertiary = Color(0xFF1A1A24);
  static final darkBackgroundGlass = const Color(0xFF111118).withOpacity(0.75);
  static const darkSurfaceElevated = Color(0xFF1E1E2E);
  static final darkBorderSubtle = Colors.white.withOpacity(0.06);
  static final darkBorderMedium = Colors.white.withOpacity(0.12);
  static const darkTextPrimary = Color(0xFFF2F2F7);
  static const darkTextSecondary = Color(0xFF8E8E9A);
  static const darkTextTertiary = Color(0xFF48484F);

  // ─── LIGHT MODE ───
  static const lightBackground = Color(0xFFF2F2F7);
  static const lightBackgroundSecondary = Color(0xFFFFFFFF);
  static const lightBackgroundTertiary = Color(0xFFF2F2F7);
  static final lightBackgroundGlass = const Color(0xFFF2F2F7).withOpacity(0.80);
  static const lightSurfaceElevated = Color(0xFFFFFFFF);
  static final lightBorderSubtle = Colors.black.withOpacity(0.06);
  static final lightBorderMedium = Colors.black.withOpacity(0.12);
  static const lightTextPrimary = Color(0xFF1C1C1E);
  static const lightTextSecondary = Color(0xFF6C6C70);
  static const lightTextTertiary = Color(0xFFAEAEB2);

  // ─── ACCENT COLORS (default indigo-violet) ───
  static const defaultAccent = Color(0xFF7C6FE0);
  static const defaultAccentLight = Color(0xFF5E4FD1);

  // ─── SEMANTIC COLORS ───
  static const success = Color(0xFF34C759);
  static final successSurface = const Color(0xFF34C759).withOpacity(0.12);
  static const warning = Color(0xFFFF9F0A);
  static final warningSurface = const Color(0xFFFF9F0A).withOpacity(0.12);
  static const destructive = Color(0xFFFF453A);
  static final destructiveSurface = const Color(0xFFFF453A).withOpacity(0.12);
  static const destructiveLight = Color(0xFFFF3B30);

  // ─── FOLDER PALETTE ───
  static const folderPalette = <String, Color>{
    'Violet': Color(0xFF7C6FE0),
    'Rose': Color(0xFFE06F9B),
    'Amber': Color(0xFFE09A3F),
    'Emerald': Color(0xFF3FB87A),
    'Sky': Color(0xFF3F8FE0),
    'Coral': Color(0xFFE0613F),
    'Slate': Color(0xFF6F8EA0),
    'Plum': Color(0xFF9B6FE0),
  };

  static const folderPaletteList = [
    Color(0xFF7C6FE0),
    Color(0xFFE06F9B),
    Color(0xFFE09A3F),
    Color(0xFF3FB87A),
    Color(0xFF3F8FE0),
    Color(0xFFE0613F),
    Color(0xFF6F8EA0),
    Color(0xFF9B6FE0),
  ];

  static const folderPaletteNames = [
    'Violet', 'Rose', 'Amber', 'Emerald', 'Sky', 'Coral', 'Slate', 'Plum',
  ];

  // ─── FILE TYPE COLORS ───
  static const pdfColor = Color(0xFFE0613F);
  static const docxColor = Color(0xFF3F8FE0);
  static const pptxColor = Color(0xFFE09A3F);

  /// Get folder color by name, defaulting to Violet.
  static Color getFolderColor(String colorName) {
    return folderPalette[colorName] ?? folderPalette['Violet']!;
  }

  /// Get file type color.
  static Color getFileTypeColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return pdfColor;
      case 'docx':
      case 'doc':
        return docxColor;
      case 'pptx':
      case 'ppt':
        return pptxColor;
      default:
        return defaultAccent;
    }
  }

  /// Get accent glow for dark mode
  static Color accentGlow(Color accent) => accent.withOpacity(0.20);

  /// Get accent surface
  static Color accentSurface(Color accent) => accent.withOpacity(0.12);
}
