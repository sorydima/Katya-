import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
  final _searchController = TextEditingController();
  bool _isSearchMode = false;
  bool _canSend = false;

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
    _searchController.dispose();
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
    setState(() {
      _canSend = false;
    });

    try {
      await _messageProvider.sendMessage(text);
    } catch (e, st) {
      // Log the underlying error for debugging while showing a friendly message to the user
      // ignore: avoid_print
      print('Matrix send message error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('messages.messageFailed'.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final matrixProvider = Provider.of<MatrixProvider>(context);
    final room = matrixProvider.getRoom(widget.roomId);

    if (room == null) {
      return Scaffold(
        body: Center(child: Text('errors.notFound'.tr())),
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
              onPressed: () => _showRoomInfo(room),
            ),
            Consumer<MatrixMessageProvider>(
              builder: (context, provider, _) {
                if (_isSearchMode) {
                  return Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_upward),
                        tooltip: 'common.previous'.tr(),
                        onPressed:
                            provider.hasSearchResults ? provider.navigateToPreviousSearchResult : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_downward),
                        tooltip: 'common.next'.tr(),
                        onPressed: provider.hasSearchResults ? provider.navigateToNextSearchResult : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'common.close'.tr(),
                        onPressed: () {
                          setState(() {
                            _isSearchMode = false;
                          });
                          _searchController.clear();
                          provider.clearSearch();
                        },
                      ),
                    ],
                  );
                }

                return IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'common.search'.tr(),
                  onPressed: () {
                    setState(() {
                      _isSearchMode = true;
                    });
                  },
                );
              },
            ),
          ],
          bottom: _isSearchMode
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Consumer<MatrixMessageProvider>(
                      builder: (context, provider, _) {
                        final resultsCount = provider.searchResults.length;
                        final currentIndex = provider.currentSearchIndex;

                        return TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'common.search'.tr(),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: resultsCount > 0 && currentIndex >= 0
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Center(
                                      widthFactor: 1,
                                      child: Text(
                                        '${currentIndex + 1}/$resultsCount',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ),
                                  )
                                : null,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          textInputAction: TextInputAction.search,
                          onChanged: (value) {
                            provider.searchMessages(value.trim());
                            if (provider.hasSearchResults) {
                              provider.navigateToSearchResult(provider.currentSearchIndex);
                            }
                          },
                          onSubmitted: (value) {
                            provider.searchMessages(value.trim());
                            if (provider.hasSearchResults) {
                              provider.navigateToSearchResult(provider.currentSearchIndex);
                            }
                          },
                        );
                      },
                    ),
                  ),
                )
              : null,
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

                  if (provider.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'messages.conversation'.tr(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'messages.startConversation'.tr(),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
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
                hintText: 'messages.messageContent'.tr(),
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
              onChanged: (value) {
                setState(() {
                  _canSend = value.trim().isNotEmpty;
                });
              },
              onSubmitted: (_) => _sendMessage(),
            ),
          ),

          // Send button
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _canSend ? _sendMessage : null,
          ),
        ],
      ),
    );
  }

  void _showRoomInfo(dynamic room) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'protocols.matrix'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('messages.conversation'.tr()),
                subtitle: Text(room.displayname ?? ''),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('messages.roomIdOrAlias'.tr()),
                subtitle: Text(room.id?.toString() ?? ''),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
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
