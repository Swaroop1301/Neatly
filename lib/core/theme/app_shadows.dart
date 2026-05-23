import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Shadow definitions.
/// Dark mode uses colored glows, light mode uses standard elevation shadows.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> cardDark(Color accent) => [
        BoxShadow(
          color: Colors.black.withOpacity(0.40),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.20),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> cardAccentDark(Color accent) => [
        BoxShadow(
          color: accent.withOpacity(0.20),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.20),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> fabDark(Color accent) => [
        BoxShadow(
          color: accent.withOpacity(0.35),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.30),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static final List<BoxShadow> cardLight = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> fabLight(Color accent) => [
        BoxShadow(
          color: accent.withOpacity(0.30),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.10),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
}
