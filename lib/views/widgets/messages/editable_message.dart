import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/global/colors.dart';
import 'package:katya/global/dimensions.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/store/index.dart';
import 'package:katya/views/widgets/messages/message_edit_dialog.dart';

class EditableMessage extends StatelessWidget {
  final Message message;
  final bool isUserSent;
  final Function(Message) onEdit;
  final Function(Message) onDelete;
  final Widget child;

  const EditableMessage({
    super.key,
    required this.message,
    required this.isUserSent,
    required this.onEdit,
    required this.onDelete,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isUserSent) return child;

    return GestureDetector(
      onLongPress: () => _showContextMenu(context),
      child: child,
    );
  }

  void _showContextMenu(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);
    final room = store.state.roomStore.rooms[message.roomId];

    if (room == null) return;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(context, room);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  onDelete(message);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditDialog(BuildContext context, Room room) async {
    final result = await showMessageEditDialog(
      context: context,
      message: message,
      room: room,
    );

    if (result == true) {
      onEdit(message);
    }
  }
}
