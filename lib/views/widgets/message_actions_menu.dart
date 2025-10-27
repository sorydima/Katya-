import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/store/events/edit/actions.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/store/index.dart';

class MessageActionsMenu extends StatelessWidget {
  final Message message;
  final Offset? position;
  final bool isOwnMessage;

  const MessageActionsMenu({
    super.key,
    required this.message,
    this.position,
    this.isOwnMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, void Function()>(
      converter: (store) => () {
        final messageId = message.id;
        if (messageId != null) {
          store.dispatch(toggleMessageEdit(messageId, isEditing: false));
        }
      },
      builder: (context, toggleEdit) {
        return PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                toggleEdit();
              case 'delete':
                _showDeleteConfirmation(context, message);
              case 'reply':
                // TODO: Implement reply functionality
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            if (isOwnMessage) ...[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
            const PopupMenuItem<String>(
              value: 'reply',
              child: Text('Reply'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Message message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete message'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMessage(context, message);
              },
              child: const Text('DELETE', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage(BuildContext context, Message message) {
    final store = StoreProvider.of<AppState>(context);
    final messageId = message.id;
    final roomId = message.roomId;
    
    if (messageId != null && roomId != null) {
      store.dispatch(deleteMessage(
        eventId: messageId,
        roomId: roomId,
        reason: 'User requested deletion',
      ));
    }
  }
}
