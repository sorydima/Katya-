import 'package:flutter/material.dart';

class MatrixTypingIndicator extends StatelessWidget {
  final List<String> typingUsers;
  final bool showIndicator;

  const MatrixTypingIndicator({
    super.key,
    this.typingUsers = const [],
    this.showIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!showIndicator || typingUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final typingText =
        typingUsers.length == 1 ? '${typingUsers.first} is typing...' : '${typingUsers.length} people are typing...';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            typingText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
