import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/global/colors.dart';
import 'package:katya/store/events/messages/actions.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/rooms/room/model.dart';

class MessageEditDialog extends StatefulWidget {
  final Message message;
  final Room room;
  final Function? onClose;

  const MessageEditDialog({
    super.key,
    required this.message,
    required this.room,
    this.onClose,
  });

  @override
  State<MessageEditDialog> createState() => _MessageEditDialogState();
}

class _MessageEditDialogState extends State<MessageEditDialog> {
  late TextEditingController _controller;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.message.body ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_controller.text.trim().isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final store = StoreProvider.of<AppState>(context);

      editMessage(
        store,
        room: widget.room,
        message: widget.message,
        newBody: _controller.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update message: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Message'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 5,
            minLines: 3,
            decoration: const InputDecoration(
              labelText: 'Edit Message',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _handleSubmit(),
          ),
          const SizedBox(height: 16),
          if (_isSubmitting) const LinearProgressIndicator(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}

Future<bool?> showMessageEditDialog({
  required BuildContext context,
  required Message message,
  required Room room,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => MessageEditDialog(
      message: message,
      room: room,
    ),
  );
}
