import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

/// Colored file type icon block (PDF, DOCX, PPTX).
class FileTypeIcon extends StatelessWidget {
  final String fileType;
  final double size;

  const FileTypeIcon({
    super.key,
    required this.fileType,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getFileTypeColor(fileType);
    final label = _getLabel(fileType);

    return Container(
      width: size,
      height: size + 4,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.22,
          ),
        ),
      ),
    );
  }

  String _getLabel(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return 'PDF';
      case 'docx':
      case 'doc':
        return 'DOC';
      case 'pptx':
      case 'ppt':
        return 'PPT';
      default:
        return type.toUpperCase();
    }
  }
}
