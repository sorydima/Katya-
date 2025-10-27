import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/rooms/room/model.dart';
import 'package:katya/store/user/model.dart';
import 'package:katya/views/widgets/messages/message_widget.dart';
import 'package:katya/views/widgets/messages/typing_indicator.dart';

class OptimizedMessageList extends StatefulWidget {
  final String roomId;
  final ScrollController scrollController;
  final bool showAvatars;
  final Function(Message?)? onSelectReply;
  final void Function({Message? message, User? user, String? userId})? onViewUserDetails;
  final void Function(Message?)? onToggleSelectedMessage;

  const OptimizedMessageList({
    super.key,
    required this.roomId,
    required this.scrollController,
    this.showAvatars = true,
    this.onSelectReply,
    this.onViewUserDetails,
    this.onToggleSelectedMessage,
  });

  @override
  _OptimizedMessageListState createState() => _OptimizedMessageListState();
}

class _OptimizedMessageListState extends State<OptimizedMessageList> {
  static const _pageSize = 50;
  final PagingController<int, Message> _pagingController = PagingController(firstPageKey: 0);
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final store = StoreProvider.of<AppState>(context);
      final messages = _getMessages(store.state, widget.roomId);

      final isLastPage = messages.length < _pageSize;

      if (isLastPage) {
        _pagingController.appendLastPage(messages);
      } else {
        final nextPageKey = pageKey + messages.length;
        _pagingController.appendPage(messages, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  List<Message> _getMessages(AppState state, String roomId) {
    // Implement message retrieval logic here
    // This should return paginated messages for the room
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _MessageListProps>(
      distinct: true,
      converter: (store) => _MessageListProps.fromStore(store, widget.roomId),
      builder: (context, props) {
        return RefreshIndicator(
          onRefresh: () => Future.sync(() => _pagingController.refresh()),
          child: PagedListView<int, Message>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Message>(
              itemBuilder: (context, message, index) {
                // Group messages by user and time
                final messages = props.messages;
                final isSameUser = index < messages.length - 1 && messages[index + 1].senderId == message.senderId;
                final isWithinTime = index < messages.length - 1 &&
                    message.originServerTs.difference(messages[index + 1].originServerTs).inMinutes < 5;

                final showAvatar = widget.showAvatars && !(isSameUser && isWithinTime) && !message.isOwn;
                final showTimestamp = index == 0 ||
                    !isSameUser ||
                    !isWithinTime ||
                    messages[index - 1]
                            .originServerTs
                            .difference(
                              message.originServerTs,
                            )
                            .inMinutes >
                        5;

                return MessageWidget(
                  key: ValueKey(message.eventId),
                  message: message,
                  isOwnMessage: message.isOwn,
                  showAvatar: showAvatar,
                  showTimestamp: showTimestamp,
                  isGrouped: isSameUser && isWithinTime,
                  onSelectReply: widget.onSelectReply,
                  onViewUserDetails: widget.onViewUserDetails,
                  onToggleSelected: widget.onToggleSelectedMessage,
                );
              },
              firstPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
              newPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
              noItemsFoundIndicatorBuilder: (context) => _buildEmptyState(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No messages yet. Send a message to start the conversation!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

class _MessageListProps {
  final Room room;
  final List<Message> messages;
  final User currentUser;
  final bool isLoading;

  _MessageListProps({
    required this.room,
    required this.messages,
    required this.currentUser,
    required this.isLoading,
  });

  static _MessageListProps fromStore(Store<AppState> store, String roomId) {
    return _MessageListProps(
      room: store.state.rooms[roomId] ?? Room(id: roomId),
      messages: store.state.events.messages[roomId] ?? [],
      currentUser: store.state.auth.user,
      isLoading: store.state.events.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _MessageListProps &&
        other.room == room &&
        other.messages == messages &&
        other.currentUser == currentUser &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => Object.hash(room, messages, currentUser, isLoading);
}
