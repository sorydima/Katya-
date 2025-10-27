import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/store/events/edit/actions.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/store/events/reactions/actions.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/rooms/room/model.dart';
import 'package:katya/store/user/model.dart';
import 'package:katya/views/widgets/message_actions_menu.dart';
import 'package:katya/views/widgets/message_editor.dart';
import 'package:katya/views/widgets/message_item.dart';

class MessageListEnhanced extends StatefulWidget {
  final String roomId;
  final List<Message> messages;
  final bool showAvatars;
  final Message? selectedMessage;
  final Function(Message?)? onToggleSelectedMessage;
  final Function({Message? message, String? userId})? onViewUserDetails;
  final Function(Message message, String reaction)? onReaction;
  final Function(Message message, String newText)? onEdit;
  final Function(Message message)? onDelete;
  final Function(Message message)? onReply;
  final Function(Message message)? onCopy;
  final Function(Message message)? onShare;

  const MessageListEnhanced({
    super.key,
    required this.roomId,
    required this.messages,
    this.showAvatars = true,
    this.selectedMessage,
    this.onToggleSelectedMessage,
    this.onViewUserDetails,
    this.onReaction,
    this.onEdit,
    this.onDelete,
    this.onReply,
    this.onCopy,
    this.onShare,
  });

  @override
  _MessageListEnhancedState createState() => _MessageListEnhancedState();
}

class _MessageListEnhancedState extends State<MessageListEnhanced> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, bool> _editingMessages = {};
  final Map<String, TextEditingController> _editControllers = {};

  @override
  void dispose() {
    _scrollController.dispose();
    for (final controller in _editControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleEdit(Message message, String newText) {
    widget.onEdit?.call(message, newText);
    setState(() {
      _editingMessages[message.id] = false;
      _editControllers[message.id]?.dispose();
      _editControllers.remove(message.id);
    });
  }

  void _startEditing(Message message) {
    setState(() {
      _editingMessages[message.id] = true;
      _editControllers[message.id] = TextEditingController(text: message.body);
    });
  }

  void _cancelEditing(Message message) {
    setState(() {
      _editingMessages[message.id] = false;
      _editControllers[message.id]?.dispose();
      _editControllers.remove(message.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        final isSelected = widget.selectedMessage?.id == message.id;
        final isEditing = _editingMessages[message.id] ?? false;

        return StoreConnector<AppState, _MessageItemViewModel>(
          converter: (store) => _MessageItemViewModel(
            currentUser: store.state.authStore.user,
            isEncrypted: store.state.roomStore.rooms[widget.roomId]?.encryptionEnabled ?? false,
          ),
          builder: (context, viewModel) {
            final isOwnMessage = message.sender == viewModel.currentUser.userId;

            if (isEditing) {
              return MessageEditor(
                initialText: message.body ?? '',
                onSave: (text) => _handleEdit(message, text),
                onCancel: () => _cancelEditing(message),
              );
            }

            return MessageItem(
              key: ValueKey('message_${message.id}'),
              message: message,
              isOwnMessage: isOwnMessage,
              showAvatar: widget.showAvatars,
              backgroundColor: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : null,
              onTap: () => widget.onToggleSelectedMessage?.call(
                isSelected ? null : message,
              ),
              onLongPress: () => _showMessageMenu(context, message, viewModel),
              onAvatarTap: () => widget.onViewUserDetails?.call(
                message: message,
                userId: message.sender,
              ),
              content: Text(
                message.body ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              timestamp: Text(
                _formatTime(message.originServerTs),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              status: _buildStatusIndicator(message),
              avatar: CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  message.sender[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              actions: [
                if (isOwnMessage) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16),
                    onPressed: () => _startEditing(message),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    onPressed: () => widget.onDelete?.call(message),
                    tooltip: 'Delete',
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.reply, size: 16),
                  onPressed: () => widget.onReply?.call(message),
                  tooltip: 'Reply',
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMessageMenu(BuildContext context, Message message, _MessageItemViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MessageActionsMenu(
        message: message,
        isOwnMessage: message.sender == viewModel.currentUser.userId,
        isEncrypted: viewModel.isEncrypted,
        onReply: () {
          Navigator.pop(context);
          widget.onReply?.call(message);
        },
        onEdit: () {
          Navigator.pop(context);
          _startEditing(message);
        },
        onDelete: () {
          Navigator.pop(context);
          widget.onDelete?.call(message);
        },
        onCopy: () {
          Navigator.pop(context);
          widget.onCopy?.call(message);
        },
        onShare: () {
          Navigator.pop(context);
          widget.onShare?.call(message);
        },
        onReaction: (reaction) {
          Navigator.pop(context);
          widget.onReaction?.call(message, reaction);
        },
      ),
    );
  }

  Widget? _buildStatusIndicator(Message message) {
    if (message.status == MessageStatus.SENDING) {
      return const Padding(
        padding: EdgeInsets.only(left: 4.0),
        child: Icon(Icons.access_time, size: 14),
      );
    } else if (message.status == MessageStatus.ERROR) {
      return const Padding(
        padding: EdgeInsets.only(left: 4.0),
        child: Icon(Icons.error_outline, size: 14, color: Colors.red),
      );
    } else if (message.status == MessageStatus.SENT) {
      return const Padding(
        padding: EdgeInsets.only(left: 4.0),
        child: Icon(Icons.check, size: 14, color: Colors.green),
      );
    }
    return null;
  }

  String _formatTime(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _MessageItemViewModel {
  final User currentUser;
  final bool isEncrypted;

  _MessageItemViewModel({
    required this.currentUser,
    required this.isEncrypted,
  });
}
