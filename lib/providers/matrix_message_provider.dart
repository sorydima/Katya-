import 'dart:async';

import 'package:flutter/material.dart' hide MatrixUtils;
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/utils/matrix_utils.dart';
import 'package:matrix/matrix.dart';

class MatrixMessageProvider extends ChangeNotifier {
  final String roomId;
  final Room? matrixRoom;
  final ScrollController scrollController;

  // State
  List<Message> _messages = [];
  bool _isLoadingOlder = false;
  bool _hasMoreMessages = true;
  bool _isInitialized = false;
  String? _searchQuery;
  List<Message> _searchResults = [];
  int _currentSearchIndex = -1;
  final bool _isLoading = false;
  final bool _shouldAutoScroll = true;

  // Getters
  List<Message> get messages => _messages;
  bool get isLoadingOlder => _isLoadingOlder;
  bool get hasMoreMessages => _hasMoreMessages;
  bool get isInitialized => _isInitialized;
  String? get searchQuery => _searchQuery;
  List<Message> get searchResults => _searchResults;
  int get currentSearchIndex => _currentSearchIndex;
  bool get hasSearchResults => _searchResults.isNotEmpty;
  bool get isLoading => _isLoading;
  bool get shouldAutoScroll => _shouldAutoScroll;

  Future<void> loadInitialMessages() async {
    await _loadInitialMessages();
  }

  Future<void> sendMessage(String text, {String? inReplyTo}) async {
    if (matrixRoom == null || text.isEmpty) return;

    try {
      await matrixRoom!.sendTextEvent(
        text,
      );
    } catch (e) {
      // Handle error
      print('Error sending message: $e');
    }
  }

  Future<void> editMessage(String messageId, String newText) async {
    if (matrixRoom == null) return;

    try {
      // For now, just send a new message with the edited text
      // In a real implementation, you'd use the Matrix edit event format
      await matrixRoom!.sendTextEvent(newText);
    } catch (e) {
      // Handle error
      print('Error editing message: $e');
    }
  }

  // Stream subscriptions
  StreamSubscription<String>? _timelineSubscription;
  StreamSubscription<SyncUpdate>? _syncSubscription;

  MatrixMessageProvider({
    required this.roomId,
    required this.matrixRoom,
    required this.scrollController,
  }) {
    _init();
  }

  Future<void> _init() async {
    if (_isInitialized) return;

    // Load initial messages
    await _loadInitialMessages();

    // Set up listeners
    _setupEventListeners();

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadInitialMessages() async {
    if (matrixRoom == null) return;

    try {
      // Load the most recent messages
      final timeline = await matrixRoom!.getTimeline();
      final events = timeline.events.take(50).toList();

      _messages =
          events.where((event) => !MatrixUtils.isRedaction(event)).map((event) => _eventToMessage(event)).toList();

      _hasMoreMessages = _messages.length >= 50; // If we got a full page, there might be more

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading initial messages: $e');
      // Handle error appropriately
    }
  }

  Future<void> loadOlderMessages() async {
    if (_isLoadingOlder || !_hasMoreMessages || matrixRoom == null) return;

    _isLoadingOlder = true;
    notifyListeners();

    try {
      final oldestEvent = _messages.isNotEmpty ? await matrixRoom!.getEventById(_messages.last.id!) : null;

      final timeline = await matrixRoom!.getTimeline();
      final events = timeline.events.skip(_messages.length).take(50).toList();

      if (events.isEmpty) {
        _hasMoreMessages = false;
      } else {
        final newMessages =
            events.where((event) => !MatrixUtils.isRedaction(event)).map((event) => _eventToMessage(event)).toList();

        _messages.addAll(newMessages);
      }
    } catch (e) {
      debugPrint('Error loading older messages: $e');
      // Handle error appropriately
    } finally {
      _isLoadingOlder = false;
      notifyListeners();
    }
  }

  void _setupEventListeners() {
    if (matrixRoom == null) return;

    // Listen to new events in the room
    _timelineSubscription = matrixRoom!.onUpdate.stream.listen((eventId) async {
      final event = await matrixRoom!.getEventById(eventId);
      if (event != null && !MatrixUtils.isRedaction(event)) {
        _handleNewEvent(event);
      }
    });

    // Listen to sync updates for read receipts and typing notifications
    _syncSubscription = matrixRoom!.client.onSync.stream.listen((syncUpdate) {
      // Handle read receipts and typing notifications
      _handleSyncUpdate(syncUpdate);
    });
  }

  void _handleNewEvent(Event event) {
    // Check if this is an edit to an existing message
    if (MatrixUtils.isEdit(event)) {
      _handleEditEvent(event);
      return;
    }

    // Handle new message
    final message = _eventToMessage(event);
    _messages.insert(0, message);

    // If we're near the bottom, auto-scroll to the new message
    if (_shouldAutoScrollToBottom()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }

    notifyListeners();
  }

  void _handleEditEvent(Event editEvent) {
    final targetEventId = MatrixUtils.getEditTargetId(editEvent);
    if (targetEventId == null) return;

    final index = _messages.indexWhere((msg) => msg.id == targetEventId);
    if (index != -1) {
      // Update the existing message with the edited content
      final updatedMessage = _eventToMessage(editEvent);
      _messages[index] = updatedMessage;
      notifyListeners();
    }
  }

  void _handleSyncUpdate(SyncUpdate update) {
    // Handle read receipts, typing notifications, etc.
    // This is a simplified version - in a real app, you'd update the UI accordingly
    notifyListeners();
  }

  bool _shouldAutoScrollToBottom() {
    if (!scrollController.hasClients) return false;

    // Auto-scroll if we're near the bottom of the list
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    return currentScroll <= maxScroll + 200; // 200px from bottom
  }

  // Search functionality
  void searchMessages(String query) {
    if (query.isEmpty) {
      _searchQuery = null;
      _searchResults = [];
      _currentSearchIndex = -1;
    } else {
      _searchQuery = query.toLowerCase();
      _searchResults =
          _messages.where((message) => message.body?.toLowerCase().contains(_searchQuery!) ?? false).toList();
      _currentSearchIndex = _searchResults.isNotEmpty ? 0 : -1;
    }

    notifyListeners();
  }

  void navigateToSearchResult(int index) {
    if (index < 0 || index >= _searchResults.length) return;

    _currentSearchIndex = index;
    _scrollToMessage(_searchResults[index].id!);
    notifyListeners();
  }

  void navigateToNextSearchResult() {
    if (_searchResults.isEmpty) return;

    _currentSearchIndex = (_currentSearchIndex + 1) % _searchResults.length;
    _scrollToMessage(_searchResults[_currentSearchIndex].id!);
    notifyListeners();
  }

  void navigateToPreviousSearchResult() {
    if (_searchResults.isEmpty) return;

    _currentSearchIndex = (_currentSearchIndex - 1) % _searchResults.length;
    if (_currentSearchIndex < 0) {
      _currentSearchIndex = _searchResults.length - 1;
    }
    _scrollToMessage(_searchResults[_currentSearchIndex].id!);
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = null;
    _searchResults = [];
    _currentSearchIndex = -1;
    notifyListeners();
  }

  void _scrollToMessage(String messageId) {
    // In a real app, you'd scroll to the message with the given ID
    // This is a simplified version
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      // Calculate the position to scroll to
      final position = index * 100.0; // Approximate height per message
      scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Message actions are defined above

  Future<void> deleteMessage(String messageId) async {
    if (matrixRoom == null) return;

    try {
      // For now, we'll implement a simple deletion
      // In a real implementation, you'd use the Matrix redaction API
      print('Deleting message: $messageId');
      // The redaction will be handled via the event listener
    } catch (e) {
      debugPrint('Error deleting message: $e');
      // Handle error appropriately
    }
  }

  Future<void> addReaction(String messageId, String emoji) async {
    if (matrixRoom == null) return;

    try {
      // For now, we'll implement a simple reaction
      // In a real implementation, you'd use the Matrix reaction API
      print('Adding reaction $emoji to message: $messageId');
      // The reaction will be handled via the event listener
    } catch (e) {
      debugPrint('Error adding reaction: $e');
      // Handle error appropriately
    }
  }

  // Helper method to convert a Matrix event to our Message model
  Message _eventToMessage(Event event) {
    return Message(
      id: event.eventId,
      sender: event.senderId,
      timestamp: event.originServerTs.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      type: event.type,
      roomId: event.roomId,
      body: event.body ?? '',
    );
  }

  @override
  void dispose() {
    _timelineSubscription?.cancel();
    _syncSubscription?.cancel();
    super.dispose();
  }
}
