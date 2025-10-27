import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/user/model.dart';
import 'package:katya/views/widgets/message_actions_menu.dart';
import 'package:katya/views/widgets/message_editor.dart';
import 'package:katya/views/widgets/message_item.dart';

class EnhancedMessageList extends StatefulWidget {
  final String roomId;
  final List<Message> messages;
  final bool showAvatars;
  final bool showEncryptionStatus;
  final Message? selectedMessage;
  final Function(Message?)? onToggleSelectedMessage;
  final Function({Message? message, String? userId})? onViewUserDetails;
  final Function(Message message, String reaction)? onReaction;
  final Function(Message message, String newText)? onEdit;
  final Function(Message message)? onDelete;
  final Function(Message message)? onReply;
  final Function(Message message)? onCopy;
  final Function(Message message)? onShare;
  final bool showReactions;

  const EnhancedMessageList({
    super.key,
    required this.roomId,
    required this.messages,
    this.showAvatars = true,
    this.showEncryptionStatus = true,
    this.selectedMessage,
    this.onToggleSelectedMessage,
    this.onViewUserDetails,
    this.onReaction,
    this.onEdit,
    this.onDelete,
    this.onReply,
    this.onCopy,
    this.onShare,
    this.showReactions = true,
  });

  @override
  _EnhancedMessageListState createState() => _EnhancedMessageListState();
}

class _EnhancedMessageListState extends State<EnhancedMessageList> {
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

  void _saveEdit(Message message) {
    final messageId = message.id;
    if (messageId == null) return;
    
    setState(() {
      _editingMessages[messageId] = false;
      _editControllers[messageId]?.dispose();
      _editControllers.remove(messageId);
    });
  }

  void _startEditing(Message message) {
    final messageId = message.id;
    if (messageId == null) return;
    
    setState(() {
      _editingMessages[messageId] = true;
      _editControllers[messageId] = TextEditingController(text: message.body);
    });
  }

  void _cancelEditing(Message message) {
    final messageId = message.id;
    if (messageId == null) return;
    
    setState(() {
      _editingMessages[messageId] = false;
      _editControllers[messageId]?.dispose();
      _editControllers.remove(messageId);
    });
  }

  void _showReactionPicker(BuildContext context, Message message) {
    final reactions = ['👍', '❤️', '😂', '😮', '😢', '🙏', '👏', '🔥', '🎉', '🤔', '😍', '👀'];

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
            const Text(
              'Add Reaction',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16.0),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: reactions.length,
              itemBuilder: (context, index) {
                final reaction = reactions[index];
                return IconButton(
                  onPressed: () {
                    widget.onReaction?.call(message, reaction);
                    Navigator.pop(context);
                  },
                  icon: Text(
                    reaction,
                    style: const TextStyle(fontSize: 24.0),
                  ),
                );
              },
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
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
                message: message,
                onSave: () => _saveEdit(message),
                onCancel: () => _cancelEditing(message),
              );
            }

            return MessageItem(
              key: ValueKey('message_${message.id}'),
              message: message,
              isOwnMessage: isOwnMessage,
              showAvatar: widget.showAvatars,
              showEncryptionStatus: widget.showEncryptionStatus,
              backgroundColor: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : null,
              onTap: () => widget.onToggleSelectedMessage?.call(
                isSelected ? null : message,
              ),
              onLongPress: () => _showMessageMenu(context, message, viewModel),
              onAvatarTap: () => widget.onViewUserDetails?.call(
                message: message,
                userId: message.sender,
              ),
              onReactionTap: widget.showReactions ? (reaction) => widget.onReaction?.call(message, reaction) : null,
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
                  (message.sender?.isNotEmpty ?? false) ? message.sender![0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              showMenu: true,
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
      ),
    );
  }

  Widget? _buildStatusIndicator(Message message) {
    if (message.failed) {
      return const Tooltip(
        message: 'Failed to send message',
        child: Icon(Icons.error_outline, size: 16, color: Colors.red),
      );
    } else if (message.pending || message.syncing) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      );
    } else if (message.edited) {
      return Tooltip(
        message: 'Edited',
        child: Text(
          'edited',
          style: TextStyle(
            fontSize: 10,
            fontStyle: FontStyle.italic,
            color: Theme.of(context).hintColor,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
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
