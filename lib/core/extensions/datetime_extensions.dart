import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  /// Format as relative time: "Just now", "5 min ago", "2h ago", "Yesterday", "Mar 14"
  String get formatRelative {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (year == now.year) return DateFormat('MMM d').format(this);
    return DateFormat('MMM d, y').format(this);
  }

  /// Format as full date: "March 14, 2024"
  String get formatFull => DateFormat('MMMM d, y').format(this);

  /// Format as short: "Mar 14, 2024"
  String get formatShort => DateFormat('MMM d, y').format(this);
}
