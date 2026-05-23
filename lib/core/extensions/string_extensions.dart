extension StringExtensions on String {
  /// Truncate string with ellipsis.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Capitalize first letter.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Sanitize for file name (remove special chars).
  String get sanitizedFileName {
    return replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  /// Get file extension.
  String get fileExtension {
    final dotIndex = lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == length - 1) return '';
    return substring(dotIndex + 1).toLowerCase();
  }

  /// Get file name without extension.
  String get fileNameWithoutExtension {
    final dotIndex = lastIndexOf('.');
    if (dotIndex == -1) return this;
    return substring(0, dotIndex);
  }
}
