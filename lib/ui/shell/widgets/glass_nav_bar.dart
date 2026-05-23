import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

/// Floating glass pill bottom navigation bar.
class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  static const List<_NavItem> _items = [
    _NavItem(PhosphorIconsDuotone.houseSimple, 'Home'),
    _NavItem(PhosphorIconsDuotone.folders, 'Library'),
    _NavItem(PhosphorIconsDuotone.magnifyingGlass, 'Search'),
    _NavItem(PhosphorIconsDuotone.gear, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: ClipRRect(
          borderRadius: AppRadius.pillRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackgroundGlass
                    : AppColors.lightBackgroundGlass,
                borderRadius: AppRadius.pillRadius,
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorderSubtle
                      : AppColors.lightBorderSubtle,
                  width: 0.5,
                ),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.40),
                          blurRadius: 24,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_items.length, (index) {
                  final isActive = index == currentIndex;
                  return _NavBarItem(
                    item: _items[index],
                    isActive: isActive,
                    accent: accent,
                    isDark: isDark,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTabSelected(index);
                    },
                  );
                }),
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(
            begin: 0.3,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final Color accent;
  final bool isDark;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.accent,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = accent;
    final inactiveColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final color = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 3),
            // Active dot indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? activeColor : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
