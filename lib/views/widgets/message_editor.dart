import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/store/events/edit/actions.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/store/index.dart';

class MessageEditor extends StatefulWidget {
  final Message message;
  final Function? onCancel;
  final Function? onSave;

  const MessageEditor({
    super.key,
    required this.message,
    this.onCancel,
    this.onSave,
  });

  @override
  _MessageEditorState createState() => _MessageEditorState();
}

class _MessageEditorState extends State<MessageEditor> {
  late TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.message.body);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, void Function(String)>(
      converter: (store) => (String newContent) {
        final eventId = widget.message.id;
        final roomId = widget.message.roomId;
        if (eventId == null || roomId == null) return;
        
        store.dispatch(editMessage(
          eventId: eventId,
          roomId: roomId,
          newContent: newContent,
        ));
        widget.onSave?.call();
      },
      builder: (context, onSave) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit message',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(8.0),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    onSave(value);
                  }
                },
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      widget.onCancel?.call();
                    },
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: _controller.text.trim().isEmpty
                        ? null
                        : () {
                            onSave(_controller.text);
                          },
                    child: const Text('SAVE'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
