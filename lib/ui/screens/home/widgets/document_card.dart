import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/extensions/int_extensions.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../domain/models/document.dart';
import '../../../shared/file_type_icon.dart';

/// The primary document card widget.
/// This is the most important widget in the app — appears on every screen.
class DocumentCard extends StatefulWidget {
  final DocumentModel document;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onFavouriteToggle;
  final String? highlightQuery;

  const DocumentCard({
    super.key,
    required this.document,
    this.onTap,
    this.onDelete,
    this.onFavouriteToggle,
    this.highlightQuery,
  });

  @override
  State<DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<DocumentCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  double _dragOffset = 0;
  bool _showDeleteAction = false;

  void _onTapDown(TapDownDetails _) {
    HapticFeedback.selectionClick();
    setState(() => _scale = 0.98);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    final isFailed = doc.aiStatus == 'failed';
    final isPending = doc.aiStatus == 'pending';
    final isProcessing = doc.aiStatus == 'processing';

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragOffset += details.delta.dx;
          _dragOffset = _dragOffset.clamp(-100.0, 0.0);
          _showDeleteAction = _dragOffset < -60;
        });
      },
      onHorizontalDragEnd: (details) {
        if (_showDeleteAction && widget.onDelete != null) {
          HapticFeedback.heavyImpact();
          widget.onDelete!();
        }
        setState(() {
          _dragOffset = 0;
          _showDeleteAction = false;
        });
      },
      child: Stack(
        children: [
          // Delete action background
          if (_dragOffset < 0)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.destructive.withOpacity(0.15),
                  borderRadius: AppRadius.lgRadius,
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: Icon(
                  PhosphorIconsDuotone.trash,
                  color: AppColors.destructive,
                  size: 24,
                ),
              ),
            ),

          // Main card
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutExpo,
            transform: Matrix4.identity()
              ..translate(_dragOffset, 0)
              ..scale(_scale),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackgroundSecondary
                    : AppColors.lightBackgroundSecondary,
                borderRadius: AppRadius.lgRadius,
                border: Border.all(
                  color: isFailed
                      ? AppColors.destructive.withOpacity(0.3)
                      : (isDark
                          ? AppColors.darkBorderSubtle
                          : AppColors.lightBorderSubtle),
                  width: 0.5,
                ),
                boxShadow: isDark
                    ? AppShadows.cardDark(accent)
                    : AppShadows.cardLight,
              ),
              child: Row(
                children: [
                  // Failed state: red left border strip
                  if (isFailed)
                    Container(
                      width: 3,
                      height: 52,
                      margin: const EdgeInsets.only(right: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.destructive,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                  else
                    // File type icon block
                    FileTypeIcon(fileType: doc.fileType),

                  const SizedBox(width: AppSpacing.md),

                  // Center content
                  Expanded(
                    child: isPending
                        ? _buildShimmerContent(isDark)
                        : _buildContent(doc, isDark, accent),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  // Right side
                  _buildTrailing(doc, isDark, accent, isProcessing, isFailed),
                ],
              ),
            ),
          ),

          // Favourite star
          if (doc.isFavourite)
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                PhosphorIconsFill.star,
                size: 14,
                color: AppColors.warning,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerContent(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark
          ? AppColors.darkBackgroundTertiary
          : AppColors.lightBackgroundTertiary,
      highlightColor: isDark
          ? AppColors.darkBackgroundSecondary
          : AppColors.lightBackgroundSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 140,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      DocumentModel doc, bool isDark, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Display name
        Text(
          doc.displayName,
          style: AppTextStyles.titleSmall.copyWith(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // AI Summary
        if (doc.aiSummary != null) ...[
          const SizedBox(height: 4),
          Text(
            doc.aiSummary!,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        const SizedBox(height: 6),

        // Metadata row
        Row(
          children: [
            if (doc.folderName != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.getFolderColor(doc.folderColorName ?? 'Violet')
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  doc.folderName!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.getFolderColor(
                        doc.folderColorName ?? 'Violet'),
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              doc.fileSizeBytes.formatFileSize,
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              doc.uploadedAt.formatRelative,
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrailing(DocumentModel doc, bool isDark, Color accent,
      bool isProcessing, bool isFailed) {
    if (isProcessing) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(accent),
        ),
      );
    }

    if (isFailed) {
      return Icon(
        PhosphorIconsDuotone.warning,
        size: 18,
        color: AppColors.destructive,
      );
    }

    return Icon(
      PhosphorIconsDuotone.caretRight,
      size: 16,
      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
    );
  }
}
