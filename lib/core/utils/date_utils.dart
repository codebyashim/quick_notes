import 'package:intl/intl.dart';

class AppDateUtils {
  static DateTime getNextMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
  }

  static bool isExpired(DateTime expiresAt) {
    return DateTime.now().isAfter(expiresAt);
  }

  static String formatDate(DateTime dt) {
    return DateFormat('MMM d, yyyy').format(dt);
  }

  static String formatDateTime(DateTime dt) {
    return DateFormat("MMM d, yyyy 'at' h:mm a").format(dt);
  }

  static String formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  static String formatRelative(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m ${m == 1 ? 'minute' : 'minutes'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    }
    final today = DateTime(now.year, now.month, now.day);
    final dtDay = DateTime(dt.year, dt.month, dt.day);
    final daysDiff = today.difference(dtDay).inDays;
    if (daysDiff == 1) return 'Yesterday';
    if (daysDiff < 7) return '$daysDiff days ago';
    return formatDate(dt);
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
