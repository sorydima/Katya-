import 'package:flutter/material.dart';

class MessageSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback onClose;
  final bool isSearching;
  final int? resultCount;
  final int? currentResultIndex;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const MessageSearchBar({
    super.key,
    required this.onSearch,
    required this.onClose,
    this.isSearching = false,
    this.resultCount,
    this.currentResultIndex,
    this.onPrevious,
    this.onNext,
  });

  @override
  _MessageSearchBarState createState() => _MessageSearchBarState();
}

class _MessageSearchBarState extends State<MessageSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search icon
          Icon(
            Icons.search,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            size: 20,
          ),
          const SizedBox(width: 8.0),

          // Search input field
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Search messages...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
              style: theme.textTheme.bodyMedium,
              onChanged: (value) {
                widget.onSearch(value);
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  widget.onSearch(value);
                }
              },
            ),
          ),

          // Search result counter
          if (widget.isSearching && widget.resultCount != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '${widget.currentResultIndex != null ? widget.currentResultIndex! + 1 : 0}/${widget.resultCount}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),

          // Navigation buttons
          if (widget.isSearching && widget.resultCount != null && widget.resultCount! > 0) ...[
            IconButton(
              icon: Icon(
                Icons.arrow_upward,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              onPressed: widget.onPrevious,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Previous result',
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_downward,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              onPressed: widget.onNext,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Next result',
            ),
            const SizedBox(width: 4.0),
          ],

          // Close button
          IconButton(
            icon: Icon(
              Icons.close,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            onPressed: () {
              _controller.clear();
              widget.onSearch('');
              widget.onClose();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Close search',
          ),
        ],
      ),
    );
  }
}
