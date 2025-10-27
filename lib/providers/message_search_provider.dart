import 'package:flutter/material.dart';
import 'package:katya/store/events/messages/model.dart';

class MessageSearchProvider with ChangeNotifier {
  bool _isSearching = false;
  String _searchTerm = '';
  List<Message> _searchResults = [];
  int _currentResultIndex = -1;
  final Map<String, GlobalKey> _messageKeys = {};
  final ScrollController? scrollController;

  MessageSearchProvider({this.scrollController});

  bool get isSearching => _isSearching;
  String get searchTerm => _searchTerm;
  List<Message> get searchResults => _searchResults;
  int get currentResultIndex => _currentResultIndex;
  int get resultCount => _searchResults.length;
  bool get hasResults => _searchResults.isNotEmpty;

  void startSearch() {
    _isSearching = true;
    notifyListeners();
  }

  void endSearch() {
    _isSearching = false;
    _searchTerm = '';
    _searchResults = [];
    _currentResultIndex = -1;
    notifyListeners();
  }

  void setSearchTerm(String term) {
    _searchTerm = term.trim();
    _currentResultIndex = -1;
    notifyListeners();
  }

  void setSearchResults(List<Message> results) {
    _searchResults = results;
    _currentResultIndex = results.isEmpty ? -1 : 0;
    notifyListeners();
    _scrollToCurrentResult();
  }

  void nextResult() {
    if (_searchResults.isEmpty) return;

    _currentResultIndex = (_currentResultIndex + 1) % _searchResults.length;
    notifyListeners();
    _scrollToCurrentResult();
  }

  void previousResult() {
    if (_searchResults.isEmpty) return;

    _currentResultIndex = (_currentResultIndex - 1) % _searchResults.length;
    if (_currentResultIndex < 0) {
      _currentResultIndex = _searchResults.length - 1;
    }
    notifyListeners();
    _scrollToCurrentResult();
  }

  void registerMessageKey(String messageId, GlobalKey key) {
    _messageKeys[messageId] = key;
  }

  void unregisterMessageKey(String messageId) {
    _messageKeys.remove(messageId);
  }

  bool isMessageHighlighted(String messageId) {
    if (!isSearching || searchTerm.isEmpty) return false;

    final currentMessage = _currentResultIndex >= 0 && _currentResultIndex < _searchResults.length
        ? _searchResults[_currentResultIndex]
        : null;

    return currentMessage?.id == messageId;
  }

  bool isMessageInSearchResults(String messageId) {
    return _searchResults.any((msg) => msg.id == messageId);
  }

  void _scrollToCurrentResult() {
    if (_currentResultIndex < 0 || _currentResultIndex >= _searchResults.length) {
      return;
    }

    final currentMessageId = _searchResults[_currentResultIndex].id;
    final key = _messageKeys[currentMessageId];

    if (key?.currentContext != null && scrollController != null) {
      // Wait for the next frame to ensure the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final box = key!.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final position = box.localToGlobal(Offset.zero);
          final scrollPosition = scrollController!.position;
          final viewportHeight = scrollPosition.viewportDimension;

          // Calculate scroll offset to center the message
          final targetOffset = position.dy - (viewportHeight / 2) + (box.size.height / 2);

          scrollController!.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _messageKeys.clear();
    super.dispose();
  }
}
