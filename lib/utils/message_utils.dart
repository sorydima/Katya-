import 'package:intl/intl.dart';
import 'package:katya/store/events/messages/model.dart';

class MessageUtils {
  /// Groups messages by date and user for better visual grouping
  static List<dynamic> groupMessages(List<Message> messages) {
    if (messages.isEmpty) return [];

    final List<dynamic> grouped = [];
    DateTime? currentDate;
    String? currentUserId;
    List<Message> currentGroup = [];

    // Sort messages by timestamp (oldest first)
    messages.sort((a, b) => a.originServerTs.compareTo(b.originServerTs));

    for (final message in messages) {
      // Add date header if needed
      final messageDate = DateTime(
        message.originServerTs.year,
        message.originServerTs.month,
        message.originServerTs.day,
      );

      if (currentDate == null || currentDate != messageDate) {
        if (currentGroup.isNotEmpty) {
          grouped.addAll(_finalizeGroup(currentGroup, currentUserId));
          currentGroup = [];
        }
        grouped.add(_createDateHeader(message.originServerTs));
        currentDate = messageDate;
      }

      // Check if we should start a new group
      if (currentUserId != message.senderId) {
        if (currentGroup.isNotEmpty) {
          grouped.addAll(_finalizeGroup(currentGroup, currentUserId));
          currentGroup = [];
        }
        currentUserId = message.senderId;
      }

      currentGroup.add(message);
    }

    // Add the last group
    if (currentGroup.isNotEmpty) {
      grouped.addAll(_finalizeGroup(currentGroup, currentUserId));
    }

    return grouped;
  }

  static List<dynamic> _finalizeGroup(List<Message> group, String? userId) {
    if (group.isEmpty) return [];

    final firstMessage = group.first;
    final lastMessage = group.last;

    return group.asMap().entries.map((entry) {
      final index = entry.key;
      final message = entry.value;

      return {
        'type': 'message',
        'data': message,
        'isFirstInGroup': index == 0,
        'isLastInGroup': index == group.length - 1,
        'showAvatar': index == 0, // Only show avatar for first message in group
        'showTimestamp': index == group.length - 1, // Only show timestamp for last message
        'showDateHeader': index == 0, // Only show date header for first message in group
        'isContinuation': index > 0, // If this is a continuation of a message group
        'timeDiffers':
            index > 0 ? message.originServerTs.difference(group[index - 1].originServerTs).inMinutes > 5 : false,
      };
    }).toList();
  }

  static Map<String, dynamic> _createDateHeader(DateTime date) {
    return {
      'type': 'date_header',
      'date': date,
      'formattedDate': _formatDateHeader(date),
    };
  }

  static String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('EEEE').format(date); // Day of week
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }

  /// Formats a timestamp for display in the message list
  static String formatMessageTime(DateTime time, {bool showSeconds = false}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(time.year, time.month, time.day);

    if (today == messageDay) {
      if (showSeconds) {
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
      }
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (today.difference(messageDay).inDays == 1) {
      return 'Yesterday ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (today.difference(messageDay).inDays < 7) {
      return '${DateFormat('EEE').format(time)} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month}/${time.year} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Checks if two messages should be grouped together
  static bool shouldGroupMessages(Message? previous, Message current, {int maxTimeDiff = 5}) {
    if (previous == null) return false;

    final sameSender = previous.senderId == current.senderId;
    final timeDiff = current.originServerTs.difference(previous.originServerTs).inMinutes;

    return sameSender && timeDiff <= maxTimeDiff;
  }
}
