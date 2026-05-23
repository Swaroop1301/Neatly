import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_shadows.dart';

/// Floating action button with breathing pulse animation.
class UploadFab extends StatefulWidget {
  final VoidCallback onTap;
  final Color accent;
  final IconData icon;

  const UploadFab({
    super.key,
    required this.onTap,
    required this.accent,
    this.icon = PhosphorIconsBold.plus,
  });

  @override
  State<UploadFab> createState() => _UploadFabState();
}

class _UploadFabState extends State<UploadFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _breatheAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _breatheAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.accent,
            boxShadow: isDark
                ? AppShadows.fabDark(widget.accent)
                : AppShadows.fabLight(widget.accent),
          ),
          child: Icon(
            widget.icon,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 450.ms,
          curve: Curves.elasticOut,
        );
  }
}

