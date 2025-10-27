import 'dart:async';

import 'package:flutter/material.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/views/widgets/messages/matrix/date_header.dart';
import 'package:katya/views/widgets/messages/matrix/message_bubble.dart';
import 'package:katya/views/widgets/messages/matrix/typing_indicator.dart';
import 'package:matrix/matrix.dart' as matrix;

class MatrixMessageList extends StatefulWidget {
  final String roomId;
  final matrix.Room? matrixRoom;
  final bool showAvatars;
  final bool isEncrypted;
  final List<Message> messages;
  final ScrollController scrollController;
  final Function(Message)? onReplyToMessage;
  final Function(Message)? onEditMessage;
  final Function(Message)? onDeleteMessage;
  final Function(Message, String)? onAddReaction;
  final Function(Message)? onViewUserDetails;
  final Function()? onScrollToBottom;
  final Function()? onRequestOlderMessages;

  const MatrixMessageList({
    super.key,
    required this.roomId,
    this.matrixRoom,
    required this.messages,
    required this.scrollController,
    this.showAvatars = true,
    this.isEncrypted = false,
    this.onReplyToMessage,
    this.onEditMessage,
    this.onDeleteMessage,
    this.onAddReaction,
    this.onViewUserDetails,
    this.onScrollToBottom,
    this.onRequestOlderMessages,
  });

  @override
  _MatrixMessageListState createState() => _MatrixMessageListState();
}

class _MatrixMessageListState extends State<MatrixMessageList> {
  final Map<String, GlobalKey> _messageKeys = {};
  bool _showScrollToBottom = false;
  Timer? _scrollDebounce;
  bool _isLoadingOlder = false;

  @override
  void initState() {
    super.initState();
    _initMessageKeys();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(MatrixMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages != oldWidget.messages) {
      _initMessageKeys();
    }
  }

  void _initMessageKeys() {
    final newKeys = <String, GlobalKey>{};
    for (final message in widget.messages) {
      newKeys[message.id] = _messageKeys[message.id] ?? GlobalKey();
    }
    _messageKeys.clear();
    _messageKeys.addAll(newKeys);
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    // Handle scroll events for infinite loading
    if (_isNearTop() && !_isLoadingOlder) {
      _loadOlderMessages();
    }

    // Show/hide scroll to bottom button
    if (widget.scrollController.hasClients) {
      final maxScroll = widget.scrollController.position.maxScrollExtent;
      final currentScroll = widget.scrollController.offset;
      final scrollPercentage = (currentScroll / maxScroll).clamp(0.0, 1.0);

      if (scrollPercentage < 0.95 && !_showScrollToBottom) {
        setState(() => _showScrollToBottom = true);
      } else if (scrollPercentage >= 0.95 && _showScrollToBottom) {
        setState(() => _showScrollToBottom = false);
      }
    }
  }

  bool _isNearTop() {
    if (!widget.scrollController.hasClients) return false;
    return widget.scrollController.offset <= widget.scrollController.position.minScrollExtent + 100;
  }

  Future<void> _loadOlderMessages() async {
    if (_isLoadingOlder) return;

    setState(() => _isLoadingOlder = true);
    try {
      await widget.onRequestOlderMessages?.call();
    } finally {
      if (mounted) {
        setState(() => _isLoadingOlder = false);
      }
    }
  }

  void _scrollToBottom() {
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      widget.onScrollToBottom?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main message list
        CustomScrollView(
          reverse: true,
          controller: widget.scrollController,
          slivers: [
            // Loading indicator for older messages
            if (_isLoadingOlder)
              const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),

            // Messages
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final message = widget.messages[index];
                  final previousMessage = index < widget.messages.length - 1 ? widget.messages[index + 1] : null;

                  final showDateHeader = _shouldShowDateHeader(
                    message,
                    previousMessage,
                  );

                  final showAvatar = _shouldShowAvatar(
                    message,
                    previousMessage,
                  );

                  return Column(
                    children: [
                      // Date header if needed
                      if (showDateHeader)
                        DateHeader(
                          date: message.originServerTs,
                        ),

                      // Message bubble
                      MatrixMessageBubble(
                        key: _messageKeys[message.id],
                        message: message,
                        matrixEvent: _getMatrixEvent(message.id),
                        showAvatar: showAvatar,
                        showEncryptionStatus: widget.isEncrypted,
                        onReply: () => widget.onReplyToMessage?.call(message),
                        onEdit: () => widget.onEditMessage?.call(message),
                        onDelete: () => widget.onDeleteMessage?.call(message),
                        onAddReaction: (emoji) => widget.onAddReaction?.call(message, emoji),
                        onViewUserDetails:
                            widget.onViewUserDetails != null ? () => widget.onViewUserDetails!(message) : null,
                      ),
                    ],
                  );
                },
                childCount: widget.messages.length,
              ),
            ),

            // Typing indicator
            const SliverToBoxAdapter(
              child: MatrixTypingIndicator(),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
          ],
        ),

        // Scroll to bottom button
        if (_showScrollToBottom)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.small(
              onPressed: _scrollToBottom,
              child: const Icon(Icons.arrow_downward),
            ),
          ),
      ],
    );
  }

  bool _shouldShowDateHeader(Message message, Message? previousMessage) {
    if (previousMessage == null) return true;

    final currentDate = DateTime(
      message.originServerTs.year,
      message.originServerTs.month,
      message.originServerTs.day,
    );

    final previousDate = DateTime(
      previousMessage.originServerTs.year,
      previousMessage.originServerTs.month,
      previousMessage.originServerTs.day,
    );

    return currentDate != previousDate;
  }

  bool _shouldShowAvatar(Message message, Message? previousMessage) {
    if (!widget.showAvatars) return false;
    if (previousMessage == null) return true;

    // Show avatar if:
    // 1. Previous message is from a different user, or
    // 2. There's a significant time gap between messages
    return message.senderId != previousMessage.senderId ||
        message.originServerTs.difference(previousMessage.originServerTs).inMinutes > 5;
  }

  matrix.Event? _getMatrixEvent(String eventId) {
    return widget.matrixRoom?.getEventById(eventId);
  }
}
