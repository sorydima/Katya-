import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:katya/providers/message_search_provider.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/store/index.dart';
import 'package:katya/utils/message_utils.dart';
import 'package:katya/views/widgets/messages/date_header.dart';
import 'package:katya/views/widgets/messages/message_widget.dart';
import 'package:katya/views/widgets/messages/typing_indicator.dart';
import 'package:provider/provider.dart';

class ModernMessageList extends StatefulWidget {
  final String roomId;
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

  const ModernMessageList({
    super.key,
    required this.roomId,
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
  });

  @override
  _ModernMessageListState createState() => _ModernMessageListState();
}

class _ModernMessageListState extends State<ModernMessageList> {
  final PagingController<int, dynamic> _pagingController = PagingController(firstPageKey: 0);
  final Map<String, GlobalKey> _messageKeys = {};
  bool _showScrollToBottom = false;
  Timer? _scrollDebounce;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    // Initialize message keys
    for (final message in widget.messages) {
      _messageKeys[message.id] = GlobalKey();
    }

    // Listen to scroll events
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(ModernMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update message keys if messages have changed
    if (widget.messages != oldWidget.messages) {
      final newKeys = <String, GlobalKey>{};
      for (final message in widget.messages) {
        newKeys[message.id] = _messageKeys[message.id] ?? GlobalKey();
      }
      _messageKeys.clear();
      _messageKeys.addAll(newKeys);

      // Update paging controller
      _pagingController.refresh();
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _scrollDebounce?.cancel();
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
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

  Future<void> _fetchPage(int pageKey) async {
    try {
      // In a real app, you would fetch paginated messages here
      // For now, we'll just use the current messages
      final isLastPage = widget.messages.length < 50; // Assuming 50 items per page

      if (isLastPage) {
        _pagingController.appendLastPage(widget.messages);
      } else {
        final nextPageKey = pageKey + widget.messages.length;
        _pagingController.appendPage(widget.messages, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
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
        RefreshIndicator(
          onRefresh: () => Future.sync(() => _pagingController.refresh()),
          child: PagedListView<int, dynamic>(
            reverse: true,
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<dynamic>(
              itemBuilder: (context, item, index) {
                if (item is Message) {
                  final message = item;
                  final isOwnMessage = message.senderId == 'current_user_id'; // Replace with actual user ID

                  return MessageWidget(
                    key: _messageKeys[message.id],
                    message: message,
                    isOwnMessage: isOwnMessage,
                    showAvatar: widget.showAvatars && !isOwnMessage,
                    onReply: () => widget.onReplyToMessage?.call(message),
                    onEdit: () => widget.onEditMessage?.call(message),
                    onDelete: () => widget.onDeleteMessage?.call(message),
                    onAddReaction: (emoji) => widget.onAddReaction?.call(message, emoji),
                    onViewUserDetails:
                        widget.onViewUserDetails != null ? () => widget.onViewUserDetails!(message) : null,
                    showEncryptionStatus: widget.isEncrypted,
                  );
                } else if (item is Map<String, dynamic> && item['type'] == 'date_header') {
                  return DateHeader(date: item['date']);
                } else {
                  return const SizedBox.shrink();
                }
              },
              firstPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
              newPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
              noItemsFoundIndicatorBuilder: (context) => _buildEmptyState(),
            ),
          ),
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

        // Typing indicator (positioned at the bottom)
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: TypingIndicator(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Send a message to start the conversation',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
