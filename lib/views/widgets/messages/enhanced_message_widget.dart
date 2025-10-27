import 'package:flutter/material.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/store/user/model.dart';
import 'package:katya/theme/theme.dart';
import 'package:katya/views/widgets/avatars/nft_avatar.dart';

class EnhancedMessageWidget extends StatelessWidget {
  final Message message;
  final bool isOwnMessage;
  final bool showAvatar;
  final bool showTimestamp;
  final bool isGrouped;
  final Function(Message)? onSelectReply;
  final Function(Message)? onToggleSelected;
  final Function({Message? message, User? user, String? userId})? onViewUserDetails;
  final bool showEncryptionStatus;
  final bool isSelected;

  const EnhancedMessageWidget({
    super.key,
    required this.message,
    this.isOwnMessage = false,
    this.showAvatar = true,
    this.showTimestamp = true,
    this.isGrouped = false,
    this.onSelectReply,
    this.onToggleSelected,
    this.onViewUserDetails,
    this.showEncryptionStatus = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: () => _handleLongPress(context),
      onTap: () => _handleTap(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showAvatar && !isOwnMessage) _buildAvatar(context),
            if (showAvatar && isOwnMessage) const SizedBox(width: 40),
            Expanded(
              child: Column(
                crossAxisAlignment: isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (showTimestamp) _buildMessageHeader(context),
                  const SizedBox(height: 2),
                  _buildMessageBubble(context),
                  if (showEncryptionStatus) _buildEncryptionStatus(context),
                  _buildMessageStatus(context),
                ],
              ),
            ),
            if (!showAvatar && !isOwnMessage) const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 2.0),
      child: GestureDetector(
        onTap: () => onViewUserDetails?.call(
          userId: message.senderId,
          message: message,
        ),
        child: NftAvatar(
          userId: message.senderId,
          size: 32.0,
        ),
      ),
    );
  }

  Widget _buildMessageHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isOwnMessage) ...[
            Text(
              message.senderId,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            _formatTime(message.originServerTs),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isOwnMessage
            ? (isDark ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.1))
            : (isDark ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.surface),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isOwnMessage ? 16 : 4),
          bottomRight: Radius.circular(isOwnMessage ? 4 : 16),
        ),
        boxShadow: [
          if (!isGrouped)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.inReplyTo != null) _buildReplyIndicator(context),
          Text(
            message.body ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isOwnMessage ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyIndicator(BuildContext context) {
    // Implement reply indicator UI
    return const SizedBox.shrink();
  }

  Widget _buildEncryptionStatus(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 4.0, right: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.lock_outline,
            size: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(width: 4),
          Text(
            'End-to-end encrypted',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageStatus(BuildContext context) {
    if (isOwnMessage) {
      return Padding(
        padding: const EdgeInsets.only(top: 2.0, right: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Message status icon (sent, delivered, read)
            _buildStatusIcon(),
            // Message timestamp
            Text(
              _formatTime(message.originServerTs, showSeconds: false),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStatusIcon() {
    if (message.status == MessageStatus.sending) {
      return const Padding(
        padding: EdgeInsets.only(right: 4.0),
        child: SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
      );
    }

    IconData icon;
    Color? color;

    switch (message.status) {
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue;
      default:
        icon = Icons.error_outline;
        color = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Icon(icon, size: 14, color: color),
    );
  }

  void _handleTap(BuildContext context) {
    // Handle tap actions
    if (onToggleSelected != null) {
      onToggleSelected!(message);
    }
  }

  void _handleLongPress(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildMessageContextMenu(context),
    );
  }

  Widget _buildMessageContextMenu(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('Reply'),
            onTap: () {
              Navigator.pop(context);
              onSelectReply?.call(message);
            },
          ),
          if (isOwnMessage) ...[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                // Handle edit
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // Handle delete
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                onViewUserDetails?.call(userId: message.senderId);
              },
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time, {bool showSeconds = false}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(time.year, time.month, time.day);

    if (today == messageDay) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (today.difference(messageDay).inDays == 1) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
