import 'package:flutter/material.dart';

class MessageActions extends StatelessWidget {
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MessageActions({
    super.key,
    this.onReply,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onReply != null)
          IconButton(
            icon: Icon(Icons.reply, color: theme.colorScheme.primary),
            onPressed: onReply,
            tooltip: 'Reply',
          ),
        if (onEdit != null)
          IconButton(
            icon: Icon(Icons.edit, color: theme.colorScheme.primary),
            onPressed: onEdit,
            tooltip: 'Edit',
          ),
        if (onDelete != null)
          IconButton(
            icon: Icon(Icons.delete, color: theme.colorScheme.error),
            onPressed: onDelete,
            tooltip: 'Delete',
          ),
      ],
    );
  }
}
