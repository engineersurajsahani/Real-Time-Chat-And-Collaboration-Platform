import 'package:intl/intl.dart';

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  String truncate(int length, {String suffix = '...'}) {
    if (this.length <= length) return this;
    return substring(0, length) + suffix;
  }
}

extension DateTimeExtensions on DateTime {
  // Convert UTC time to IST (Indian Standard Time - UTC+5:30)
  DateTime toIST() {
    // If already in local time zone, return as is
    // Otherwise convert UTC to IST by adding 5 hours 30 minutes
    if (isUtc) {
      return add(const Duration(hours: 5, minutes: 30));
    }
    return this;
  }

  String toFormattedTime() {
    final ist = toIST();
    return DateFormat('hh:mm a').format(ist); // 12-hour format with AM/PM
  }

  String toFormattedDate() {
    final ist = toIST();
    return DateFormat('MMM dd, yyyy').format(ist);
  }

  String toFormattedDateTime() {
    final ist = toIST();
    return DateFormat('MMM dd, yyyy hh:mm a').format(ist);
  }

  bool isToday() {
    final now = DateTime.now();
    final ist = toIST();
    return ist.year == now.year && ist.month == now.month && ist.day == now.day;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final ist = toIST();
    return ist.year == yesterday.year &&
        ist.month == yesterday.month &&
        ist.day == yesterday.day;
  }

  String toRelativeTime() {
    final now = DateTime.now();
    final ist = toIST();
    final difference = now.difference(ist);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24 && isToday()) {
      return toFormattedTime();
    } else if (isYesterday()) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(ist); // Day of week
    } else {
      return toFormattedDate();
    }
  }
}
