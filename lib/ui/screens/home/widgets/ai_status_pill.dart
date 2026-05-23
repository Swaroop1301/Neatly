import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';

/// Glass pill showing AI processing status.
class AiStatusPill extends StatelessWidget {
  final int pendingCount;
  final Color accent;

  const AiStatusPill({
    super.key,
    required this.pendingCount,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: AppRadius.pillRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkBackgroundGlass
                : AppColors.lightBackgroundGlass,
            borderRadius: AppRadius.pillRadius,
            border: Border.all(
              color: accent.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'AI is sorting $pendingCount document${pendingCount == 1 ? '' : 's'}...',
                style: AppTextStyles.labelLarge.copyWith(color: accent),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 2000.ms,
          color: accent.withOpacity(0.1),
        );
  }
}
