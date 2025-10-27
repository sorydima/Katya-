import 'dart:math';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class MatrixUtils {
  /// Get the display name for a user, falling back to their localpart or user ID
  static String getDisplayName(User user, String? roomId) {
    return user.displayName ?? user.id;
  }

  /// Format a timestamp into a human-readable time string
  static String formatTime(DateTime time, {bool showSeconds = false}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final timeToCheck = DateTime(time.year, time.month, time.day);

    if (timeToCheck == today) {
      // Today - show time only
      return _formatTimeString(time, showSeconds: showSeconds);
    } else if (timeToCheck == yesterday) {
      // Yesterday - show 'Yesterday' and time
      return 'Yesterday ${_formatTimeString(time, showSeconds: showSeconds)}';
    } else if (timeToCheck.isAfter(now.subtract(const Duration(days: 7)))) {
      // Within the last week - show day and time
      return '${_getWeekday(time.weekday)} ${_formatTimeString(time, showSeconds: showSeconds)}';
    } else if (timeToCheck.year == now.year) {
      // Same year - show month, day, and time
      return '${_getMonth(time.month)} ${time.day} ${_formatTimeString(time, showSeconds: showSeconds)}';
    } else {
      // Different year - show full date and time
      return '${_getMonth(time.month)} ${time.day}, ${time.year} ${_formatTimeString(time, showSeconds: showSeconds)}';
    }
  }

  static String _formatTimeString(DateTime time, {bool showSeconds = false}) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour < 12 ? 'AM' : 'PM';

    if (showSeconds) {
      return '$hour:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')} $period';
    } else {
      return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }

  static String _getWeekday(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  static String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  /// Check if a message is from the current user
  static bool isCurrentUser(Event event, String? currentUserId) {
    return event.senderId == currentUserId;
  }

  /// Get the appropriate icon for a message status
  static IconData getMessageStatusIcon(Event event, {String? currentUserId}) {
    if (currentUserId == null || event.senderId != currentUserId) {
      return Icons.person;
    }

    // These are simplified - in a real app, you'd check the actual status
    if (event.status == EventStatus.sent) {
      return Icons.done;
    } else if (event.status == EventStatus.sent) {
      return Icons.done_all;
    } else if (event.status == EventStatus.sent) {
      return Icons.done_all;
    } else {
      return Icons.schedule;
    }
  }

  /// Get the appropriate color for a message status icon
  static Color getMessageStatusColor(Event event, BuildContext context) {
    final theme = Theme.of(context);

    if (event.status == EventStatus.error) {
      return theme.colorScheme.error;
    } else if (event.status == EventStatus.sent) {
      return theme.colorScheme.primary;
    } else if (event.status == EventStatus.sent) {
      return theme.colorScheme.primary.withOpacity(0.5);
    } else {
      return theme.textTheme.bodySmall?.color?.withOpacity(0.5) ?? Colors.grey;
    }
  }

  /// Get the appropriate tooltip for a message status
  static String getMessageStatusTooltip(Event event) {
    if (event.status == EventStatus.error) {
      return 'Failed to send';
    } else if (event.status == EventStatus.sent) {
      return 'Read';
    } else if (event.status == EventStatus.sent) {
      return 'Delivered';
    } else if (event.status == EventStatus.sent) {
      return 'Sent';
    } else {
      return 'Sending...';
    }
  }

  /// Get the appropriate icon for a file type
  static IconData getFileTypeIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;

    if (mimeType.startsWith('image/')) {
      return Icons.image;
    } else if (mimeType.startsWith('video/')) {
      return Icons.videocam;
    } else if (mimeType.startsWith('audio/')) {
      return Icons.audiotrack;
    } else if (mimeType.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (mimeType.contains('word') || mimeType.contains('document')) {
      return Icons.description;
    } else if (mimeType.contains('spreadsheet') || mimeType.contains('excel')) {
      return Icons.table_chart;
    } else if (mimeType.contains('presentation') || mimeType.contains('powerpoint')) {
      return Icons.slideshow;
    } else if (mimeType.contains('zip') || mimeType.contains('compressed')) {
      return Icons.archive;
    } else {
      return Icons.insert_drive_file;
    }
  }

  /// Format file size in a human-readable format
  static String formatFileSize(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    final digitGroups = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, digitGroups)).toStringAsFixed(decimals)} ${units[digitGroups]}';
  }

  /// Get the appropriate color for a reaction count
  static Color getReactionColor(int count, BuildContext context) {
    final theme = Theme.of(context);
    if (count == 0) return theme.colorScheme.surface;
    if (count == 1) return theme.colorScheme.surfaceContainerHighest;
    if (count <= 3) return theme.colorScheme.primaryContainer;
    return theme.colorScheme.secondaryContainer;
  }

  /// Check if a message is a redaction
  static bool isRedaction(Event event) {
    return event.type == EventTypes.Redaction;
  }

  /// Check if a message is an edit
  static bool isEdit(Event event) {
    if (event.unsigned == null) return false;
    final relations = event.unsigned!['m.relations'];
    if (relations is! Map) return false;
    return relations['m.replace'] != null;
  }

  /// Get the original message ID if this is an edit
  static String? getEditTargetId(Event event) {
    if (event.unsigned == null) return null;
    final relations = event.unsigned!['m.relations'];
    if (relations is! Map) return null;
    final replace = relations['m.replace'];
    if (replace is! Map) return null;
    return replace['event_id'] as String?;
  }

  /// Get the transaction ID for a pending message
  static String? getTransactionId(Event event) {
    return event.unsigned?['transaction_id'] as String?;
  }

  /// Get the age of a message in seconds
  static int getMessageAge(Event event) {
    return DateTime.now().millisecondsSinceEpoch - event.originServerTs.millisecondsSinceEpoch;
  }

  /// Check if a message is considered "old"
  static bool isOldMessage(Event event, {Duration threshold = const Duration(hours: 24)}) {
    return DateTime.now().difference(event.originServerTs) > threshold;
  }
}
