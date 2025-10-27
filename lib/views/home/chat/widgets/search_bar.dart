import 'package:flutter/material.dart';

class MessageSearchBar extends StatelessWidget {
  final String searchTerm;
  final int? currentResultIndex;
  final int? resultCount;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClose;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const MessageSearchBar({
    super.key,
    required this.searchTerm,
    required this.onSearchChanged,
    required this.onClose,
    this.currentResultIndex,
    this.resultCount,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search icon
          const Icon(Icons.search, size: 20, color: Colors.grey),
          const SizedBox(width: 8),

          // Search input field
          Expanded(
            child: TextField(
              controller: TextEditingController(text: searchTerm),
              onChanged: onSearchChanged,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search messages...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),

          // Result counter
          if (resultCount != null && resultCount! > 0) ...[
            Text(
              '${(currentResultIndex ?? 0) + 1}/$resultCount',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),

            // Navigation buttons
            IconButton(
              icon: const Icon(Icons.arrow_upward, size: 20),
              onPressed: onPrevious,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Previous result',
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward, size: 20),
              onPressed: onNext,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Next result',
            ),
            const SizedBox(width: 4),
          ],

          // Close button
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Close search',
          ),
        ],
      ),
    );
  }
}
