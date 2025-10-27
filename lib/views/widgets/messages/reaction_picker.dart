import 'package:flutter/material.dart';

class ReactionPicker extends StatelessWidget {
  final Function(String) onReactionSelected;
  final VoidCallback onDismiss;
  final Offset position;
  final bool isOwnMessage;

  static const List<String> defaultReactions = [
    '👍',
    '👎',
    '❤️',
    '😂',
    '😮',
    '😢',
    '🙏',
    '👏',
  ];

  const ReactionPicker({
    super.key,
    required this.onReactionSelected,
    required this.onDismiss,
    required this.position,
    this.isOwnMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Dismissal area
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // Reaction picker
        Positioned(
          left: position.dx,
          top: position.dy - 60, // Position above the tap
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(24.0),
            color: isDark ? Colors.grey[850] : Colors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final reaction in defaultReactions) _buildReactionButton(context, reaction),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReactionButton(BuildContext context, String reaction) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onReactionSelected(reaction);
          onDismiss();
        },
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Text(
            reaction,
            style: const TextStyle(fontSize: 24.0),
          ),
        ),
      ),
    );
  }
}
