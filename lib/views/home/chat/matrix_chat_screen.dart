import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/matrix_message_provider.dart';
import '../../../providers/matrix_provider.dart';
import '../../../store/events/messages/model.dart';
import '../../widgets/messages/matrix/date_header.dart';
import '../../widgets/messages/matrix/message_bubble.dart';
import '../../widgets/messages/matrix/typing_indicator.dart';

class MatrixChatScreen extends StatefulWidget {
  final String roomId;

  const MatrixChatScreen({
    super.key,
    required this.roomId,
  });

  @override
  _MatrixChatScreenState createState() => _MatrixChatScreenState();
}

class _MatrixChatScreenState extends State<MatrixChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late final MatrixMessageProvider _messageProvider;

  @override
  void initState() {
    super.initState();
    final matrixProvider = Provider.of<MatrixProvider>(context, listen: false);
    _messageProvider = MatrixMessageProvider(
      roomId: widget.roomId,
      matrixRoom: matrixProvider.getRoom(widget.roomId),
      scrollController: _scrollController,
    );

    // Load initial messages
    _messageProvider.loadInitialMessages();

    // Scroll to bottom when new messages arrive
    _messageProvider.addListener(_onNewMessages);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageProvider.removeListener(_onNewMessages);
    _messageProvider.dispose();
    super.dispose();
  }

  void _onNewMessages() {
    // Scroll to bottom when new messages arrive
    if (_messageProvider.shouldAutoScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      await _messageProvider.sendMessage(text);
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final matrixProvider = Provider.of<MatrixProvider>(context);
    final room = matrixProvider.getRoom(widget.roomId);

    if (room == null) {
      return const Scaffold(
        body: Center(child: Text('Room not found')),
      );
    }

    return ChangeNotifierProvider.value(
      value: _messageProvider,
      child: Scaffold(
        appBar: AppBar(
          title: Text(room.displayname),
          actions: [
            // Room info button
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                // TODO: Show room info
              },
            ),
            // Search button
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Implement search
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Message list
            Expanded(
              child: Consumer<MatrixMessageProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.messages.length + 1, // +1 for loading indicator
                    itemBuilder: (context, index) {
                      // Loading indicator at the bottom
                      if (index == provider.messages.length) {
                        return provider.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink();
                      }

                      final message = provider.messages[index];
                      final previousMessage =
                          index < provider.messages.length - 1 ? provider.messages[index + 1] : null;

                      // Check if we should show date header
                      final showDateHeader = _shouldShowDateHeader(message, previousMessage);

                      return Column(
                        children: [
                          // Date header if needed
                          if (showDateHeader)
                            DateHeader(date: DateTime.fromMillisecondsSinceEpoch(message.originServerTs)),

                          // Message bubble
                          MatrixMessageBubble(
                            message: message,
                            isOwnMessage: message.senderId == matrixProvider.client?.userID,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // Typing indicator
            const MatrixTypingIndicator(),

            // Message input
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attachment button
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // TODO: Show attachment options
            },
          ),

          // Message input field
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: 5,
              minLines: 1,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),

          // Send button
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  bool _shouldShowDateHeader(Message current, Message? previous) {
    if (previous == null) return true;

    final currentDate = DateTime.fromMillisecondsSinceEpoch(current.originServerTs);
    final currentDateOnly = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    final previousDate = DateTime.fromMillisecondsSinceEpoch(previous.originServerTs);
    final previousDateOnly = DateTime(
      previousDate.year,
      previousDate.month,
      previousDate.day,
    );

    return currentDateOnly != previousDateOnly;
  }

  bool _shouldShowAvatar(Message current, Message? previous) {
    if (previous == null) return true;

    // Show avatar if:
    // 1. Previous message is from a different user, or
    // 2. There's a significant time gap between messages
    final currentTime = DateTime.fromMillisecondsSinceEpoch(current.originServerTs);
    final previousTime = DateTime.fromMillisecondsSinceEpoch(previous.originServerTs);

    return current.senderId != previous.senderId || currentTime.difference(previousTime).inMinutes > 5;
  }
}
