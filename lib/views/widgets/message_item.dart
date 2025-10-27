import 'package:flutter/material.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/views/widgets/encryption_indicator.dart';
import 'package:katya/views/widgets/message_actions_menu.dart';

class MessageItem extends StatefulWidget {
  final Message message;
  final bool isOwnMessage;
  final bool showAvatar;
  final Widget? avatar;
  final Widget? content;
  final Widget? timestamp;
  final Widget? status;
  final bool showStatus;
  final bool showEncryptionStatus;
  final Widget? reactions;
  final Widget? replies;
  final Widget? replyTo;
  final Widget? header;
  final Widget? footer;
  final Color? backgroundColor;
  final Color? textColor;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool showMenu;
  final Function()? onTap;
  final Function()? onLongPress;
  final Function()? onAvatarTap;
  final Function()? onReplyTap;
  final Function(String reaction)? onReactionTap;
  final Function()? onThreadTap;

  const MessageItem({
    this.showStatus = true,
    this.showEncryptionStatus = true,
    super.key,
    required this.message,
    this.isOwnMessage = false,
    this.showAvatar = true,
    this.avatar,
    this.content,
    this.timestamp,
    this.status,
    this.reactions,
    this.replies,
    this.replyTo,
    this.header,
    this.footer,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.showMenu = true,
    this.onTap,
    this.onLongPress,
    this.onAvatarTap,
    this.onReplyTap,
    this.onReactionTap,
    this.onThreadTap,
  });

  @override
  _MessageItemState createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  final GlobalKey _menuKey = GlobalKey();
  final bool _isHovered = false;

  void _showReactionPicker() {
    if (widget.onReactionTap == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Reaction', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: ['👍', '❤️', '😂', '😮', '😢', '🙏', '👏', '🔥', '🎉', '🤔', '😍', '👀']
                  .map((reaction) => GestureDetector(
                        onTap: () {
                          widget.onReactionTap?.call(reaction);
                          Navigator.pop(context);
                        },
                        child: Text(
                          reaction,
                          style: const TextStyle(fontSize: 24.0),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactions() {
    if (widget.message.reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group reactions by body (emoji) and count them
    final reactionCounts = <String, int>{};
    for (final reaction in widget.message.reactions) {
      final emoji = reaction.body ?? '';
      reactionCounts[emoji] = (reactionCounts[emoji] ?? 0) + 1;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Wrap(
        spacing: 4.0,
        runSpacing: 4.0,
        children: reactionCounts.entries
            .map((entry) => GestureDetector(
                  onTap: () => widget.onReactionTap?.call(entry.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.5),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '${entry.key} ${entry.value}',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    if (!widget.showStatus) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.status != null) widget.status!,
          if (widget.timestamp != null) widget.timestamp!,
          if (widget.showEncryptionStatus && widget.isOwnMessage && widget.message.roomId != null)
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: EncryptionIndicator(
                roomId: widget.message.roomId!,
                size: 12,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Container(
        margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: widget.isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!widget.isOwnMessage && widget.showAvatar && widget.avatar != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: widget.onAvatarTap,
                  child: widget.avatar,
                ),
              ),
            Flexible(
              child: Column(
                crossAxisAlignment: widget.isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (widget.header != null) widget.header!,
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: widget.backgroundColor ??
                          (widget.isOwnMessage
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surfaceContainerHighest),
                      borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                      border: widget.showEncryptionStatus && !widget.isOwnMessage
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              width: 1,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: widget.isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (widget.replyTo != null) widget.replyTo!,
                        if (widget.content != null) widget.content!,
                        if (widget.reactions != null) _buildReactions(),
                        if (widget.showStatus || widget.showEncryptionStatus)
                          Column(
                            crossAxisAlignment: widget.isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              if (widget.showEncryptionStatus && widget.message.encrypted)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.lock_outline,
                                        size: 12,
                                        color: Theme.of(context).hintColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Encrypted',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    widget.isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: [
                                  if (widget.timestamp != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4.0),
                                      child: widget.timestamp,
                                    ),
                                  if (widget.status != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: widget.status,
                                    ),
                                  if (widget.isOwnMessage && widget.showStatus)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: _buildStatusIndicator(),
                                    ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  if (_isHovered && widget.showMenu && widget.isOwnMessage)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: MessageActionsMenu(
                        key: _menuKey,
                        message: widget.message,
                        isOwnMessage: widget.isOwnMessage,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
