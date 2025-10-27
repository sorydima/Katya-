# Matrix Message List Implementation

This document provides an overview of the Matrix message list implementation in the Katya app, including its architecture, components, and usage guidelines.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Components](#components)
- [State Management](#state-management)
- [Message Handling](#message-handling)
- [UI Components](#ui-components)
- [Usage](#usage)
- [Customization](#customization)
- [Performance Considerations](#performance-considerations)
- [Troubleshooting](#troubleshooting)

## Overview

The Matrix message list is a high-performance, feature-rich component designed specifically for the Matrix protocol. It handles real-time messaging, message grouping, read receipts, typing indicators, and more, while maintaining a smooth user experience.

## Architecture

The message list follows a reactive architecture with clear separation of concerns:

- **Data Layer**: Handles message fetching, caching, and synchronization with the Matrix server
- **State Management**: Manages the UI state, including message list, loading states, and user interactions
- **UI Layer**: Renders the message list and handles user interactions

## Components

### Core Components

1. **MatrixMessageList**: The main widget that displays the list of messages
2. **MatrixMessageBubble**: Renders individual message bubbles with proper styling
3. **MatrixTypingIndicator**: Shows typing indicators for users currently typing
4. **DateHeader**: Displays date separators between messages
5. **MessageActions**: Handles message context menu and interactions

### Supporting Components

1. **MatrixAvatar**: Displays user avatars with fallback to initials
2. **MessageSearchBar**: Provides in-chat message search functionality
3. **ReactionPicker**: Allows users to add reactions to messages
4. **FilePreview**: Handles previews for different file types

## State Management

The message list uses a combination of Provider and Streams for state management:

- **MatrixMessageProvider**: Manages the message list state and handles message operations
- **MessageSearchProvider**: Handles search functionality and result navigation

## Message Handling

The message list supports various message types:

- Text messages
- Image messages
- File attachments
- Video messages
- Audio messages
- Stickers
- Emoji reactions
- Read receipts
- Typing indicators

## UI Components

### Message Bubble

Each message bubble includes:
- Sender avatar (configurable)
- Message content with proper formatting
- Timestamp
- Read receipts
- Message status indicators
- Context menu

### Context Menu

The context menu provides quick access to common message actions:
- Reply
- Edit (own messages only)
- Copy
- Forward
- Delete (own messages only)
- Report (other users' messages)
- Quick reactions

## Usage

### Basic Usage

```dart
// Create a scroll controller
final _scrollController = ScrollController();

// In your widget tree
MatrixMessageList(
  roomId: roomId,
  matrixRoom: matrixRoom,
  scrollController: _scrollController,
  onReplyToMessage: (message) {
    // Handle reply
  },
  onEditMessage: (message) {
    // Handle edit
  },
  onDeleteMessage: (message) {
    // Handle delete
  },
  onAddReaction: (message, emoji) {
    // Handle reaction
  },
  onViewUserDetails: (message) {
    // Show user details
  },
);
```

### With Search Functionality

```dart
// Create a search provider
final searchProvider = MessageSearchProvider(
  scrollController: _scrollController,
);

// In your widget tree
ChangeNotifierProvider.value(
  value: searchProvider,
  child: Column(
    children: [
      // Search bar
      if (searchProvider.isSearching)
        MessageSearchBar(
          searchTerm: searchProvider.searchTerm,
          currentResultIndex: searchProvider.currentSearchIndex,
          resultCount: searchProvider.searchResults.length,
          onSearchChanged: searchProvider.search,
          onClose: searchProvider.endSearch,
          onPrevious: searchProvider.navigateToPreviousResult,
          onNext: searchProvider.navigateToNextResult,
        ),
      
      // Message list
      Expanded(
        child: MatrixMessageList(
          roomId: roomId,
          matrixRoom: matrixRoom,
          scrollController: _scrollController,
          // ... other properties
        ),
      ),
    ],
  ),
);
```

## Customization

### Theming

You can customize the appearance of the message list by providing a custom theme:

```dart
MaterialApp(
  theme: ThemeData(
    // Customize the theme to match your app's design
    primaryColor: Colors.blue,
    accentColor: Colors.blueAccent,
    // ... other theme properties
  ),
  // ...
);
```

### Custom Message Types

To add support for custom message types, extend the `MatrixMessageBubble` widget:

```dart
class CustomMessageBubble extends MatrixMessageBubble {
  const CustomMessageBubble({
    Key? key,
    required Message message,
    // ... other parameters
  }) : super(
          key: key,
          message: message,
          // ... other parameters
        );

  @override
  Widget buildMessageContent() {
    // Custom rendering for your message type
    if (message.type == 'custom_type') {
      return _buildCustomMessage();
    }
    
    // Fall back to default rendering
    return super.buildMessageContent();
  }
  
  Widget _buildCustomMessage() {
    // Your custom message rendering code
    return Container(
      // ...
    );
  }
}
```

## Performance Considerations

### Message List Optimization

- **Pagination**: Messages are loaded in pages to improve performance
- **Lazy Loading**: Images and other media are loaded lazily
- **Message Recycling**: Message widgets are recycled to minimize widget recreation
- **Efficient Updates**: Only changed messages are re-rendered

### Memory Management

- **Image Caching**: Images are cached to improve performance
- **Message Cleanup**: Old messages are unloaded when no longer needed
- **Stream Management**: Event streams are properly disposed of when no longer needed

## Troubleshooting

### Common Issues

1. **Messages not updating**
   - Ensure you're properly listening to Matrix room events
   - Check that the message provider is properly initialized
   - Verify that the Matrix client is properly connected

2. **Performance issues with large message lists**
   - Enable pagination to load messages in chunks
   - Use the `ListView.builder` with `itemExtent` for better performance
   - Consider implementing a custom `SliverList` for more control over rendering

3. **Missing avatars or display names**
   - Check that user profiles are being loaded correctly
   - Verify that the Matrix client has the necessary permissions
   - Ensure that the avatar URLs are valid and accessible

### Debugging Tips

- Use the Flutter DevTools to identify performance bottlenecks
- Enable verbose logging in the Matrix client for debugging
- Check the browser's network tab for failed requests
- Verify that all required Matrix APIs are properly implemented

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
