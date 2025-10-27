import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/store/events/messages/actions.dart';
import 'package:katya/store/events/reactions/actions.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/rooms/room/model.dart';
import 'package:katya/views/home/chat/widgets/chat-input.dart';
import 'package:katya/views/home/chat/widgets/modern_message_list.dart';
import 'package:katya/views/home/chat/widgets/search_bar.dart';
import 'package:katya/views/widgets/lifecycle.dart';

class ModernChatScreen extends StatefulWidget {
  final String roomId;
  final Room? room;
  final ScrollController scrollController;
  final TextEditingController editorController;

  const ModernChatScreen({
    super.key,
    required this.roomId,
    required this.room,
    required this.scrollController,
    required this.editorController,
  });

  @override
  _ModernChatScreenState createState() => _ModernChatScreenState();
}

class _ModernChatScreenState extends State<ModernChatScreen> with Lifecycle<ModernChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showSearchBar = false;
  String _searchTerm = '';
  List<Message> _searchResults = [];
  int _currentSearchIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search bar (conditionally shown)
          if (_showSearchBar) _buildSearchBar(),

          // Message list
          Expanded(
            child: StoreConnector<AppState, List<Message>>(
              converter: (store) => store.state.roomMessages[widget.roomId] ?? [],
              builder: (context, messages) {
                return ModernMessageList(
                  roomId: widget.roomId,
                  messages: messages,
                  scrollController: widget.scrollController,
                  isEncrypted: widget.room?.encrypted ?? false,
                  onReplyToMessage: _handleReply,
                  onEditMessage: _handleEdit,
                  onDeleteMessage: _handleDelete,
                  onAddReaction: _handleAddReaction,
                  onViewUserDetails: _showUserDetails,
                  onScrollToBottom: _scrollToBottom,
                );
              },
            ),
          ),

          // Message input
          ChatInput(
            roomId: widget.roomId,
            controller: widget.editorController,
            onSend: _handleSendMessage,
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(widget.room?.name ?? 'Chat'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _toggleSearch,
        ),
        // Add more actions as needed
      ],
    );
  }

  Widget _buildSearchBar() {
    return MessageSearchBar(
      searchTerm: _searchTerm,
      currentResultIndex: _currentSearchIndex,
      resultCount: _searchResults.length,
      onSearchChanged: _handleSearch,
      onClose: _toggleSearch,
      onPrevious: _showPreviousResult,
      onNext: _showNextResult,
    );
  }

  void _toggleSearch() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchTerm = '';
        _searchResults = [];
        _currentSearchIndex = -1;
      }
    });
  }

  void _handleSearch(String query) {
    final store = StoreProvider.of<AppState>(context);
    final messages = store.state.roomMessages[widget.roomId] ?? [];

    setState(() {
      _searchTerm = query;
      _searchResults = messages.where((msg) => msg.body?.toLowerCase().contains(query.toLowerCase()) ?? false).toList();
      _currentSearchIndex = _searchResults.isNotEmpty ? 0 : -1;
    });

    _scrollToSearchResult();
  }

  void _showPreviousResult() {
    if (_searchResults.isEmpty) return;

    setState(() {
      _currentSearchIndex = (_currentSearchIndex - 1) % _searchResults.length;
      if (_currentSearchIndex < 0) {
        _currentSearchIndex = _searchResults.length - 1;
      }
    });

    _scrollToSearchResult();
  }

  void _showNextResult() {
    if (_searchResults.isEmpty) return;

    setState(() {
      _currentSearchIndex = (_currentSearchIndex + 1) % _searchResults.length;
    });

    _scrollToSearchResult();
  }

  void _scrollToSearchResult() {
    if (_currentSearchIndex >= 0 && _currentSearchIndex < _searchResults.length) {
      final messageId = _searchResults[_currentSearchIndex].id;
      // In a real implementation, you would scroll to the message
      // using a ScrollController and the message's GlobalKey
    }
  }

  void _handleSendMessage(String text) {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(sendTextMessage(
      roomId: widget.roomId,
      text: text,
    ));
  }

  void _handleReply(Message message) {
    // Show reply UI in the input field
    widget.editorController.text = '> ${message.body}\n\n';
    widget.editorController.selection = TextSelection.collapsed(
      offset: widget.editorController.text.length,
    );
    // Focus the input field
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _handleEdit(Message message) {
    // Set message for editing
    widget.editorController.text = message.body ?? '';
    widget.editorController.selection = TextSelection.collapsed(
      offset: widget.editorController.text.length,
    );
    // Focus the input field
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _handleDelete(Message message) {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(deleteMessage(
      roomId: widget.roomId,
      messageId: message.id,
    ));
  }

  void _handleAddReaction(Message message, String emoji) {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(toggleReaction(
      roomId: widget.roomId,
      messageId: message.id,
      emoji: emoji,
    ));
  }

  void _showUserDetails(Message message) {
    // Show user details dialog or navigate to profile
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Details'),
        content: Text('User ID: ${message.senderId}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}
