import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/global/colors.dart';
import 'package:katya/global/dimensions.dart';
import 'package:katya/global/formatters.dart';
import 'package:katya/global/libs/matrix/constants.dart';
import 'package:katya/global/noop.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/store/events/messages/selectors.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/settings/models.dart';
import 'package:katya/store/settings/theme-settings/model.dart';
import 'package:katya/views/widgets/avatars/avatar.dart';
import 'package:katya/views/widgets/messages/message_edit_dialog.dart';

class MessageWidget extends StatefulWidget {
  const MessageWidget({
    super.key,
    required this.message,
    this.editorController,
    this.isUserSent = false,
    this.messageOnly = false,
    this.isNewContext = false,
    this.isLastSender = false,
    this.isNextSender = false,
    this.isEditing = false,
    this.lastRead = 0,
    this.selectedMessageId,
    this.avatarUri,
    this.displayName,
    this.currentName,
    this.themeType = ThemeType.Light,
    this.fontSize = 14.0,
    this.messageSize = 12.0,
    this.timeFormat = TimeFormat.hr12,
    this.color,
    this.luminance = 0.0,
    this.onSwipe = noop,
    this.onResend = noop,
    this.onSendEdit,
    this.onLongPress,
    this.onPressAvatar,
    this.onInputReaction,
    this.onToggleReaction,
    this.onEditMessage,
  });

  final bool messageOnly;
  final bool isNewContext;
  final bool isLastSender;
  final bool isNextSender;
  final bool isUserSent;
  final bool isEditing;

  final int lastRead;
  final double fontSize;
  final double messageSize;
  final TimeFormat timeFormat;

  final Color? color;
  final double? luminance;
  final String? avatarUri;
  final String? selectedMessageId;
  final String? displayName;
  final String? currentName;

  final Message message;
  final ThemeType themeType;
  final TextEditingController? editorController;

  final Function onSwipe;
  final Function onResend;
  final Function? onSendEdit;
  final Function? onLongPress;
  final Function? onPressAvatar;
  final Function? onInputReaction;
  final Function? onToggleReaction;
  final Function(Message)? onEditMessage;

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  @override
  bool get mounted => true;

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final selected = widget.selectedMessageId != null && widget.selectedMessageId == message.id;
    final isRead = message.timestamp < widget.lastRead;
    final showAvatar = !widget.isLastSender && !widget.isUserSent && !widget.messageOnly;
    final body = selectEventBody(message);
    final isMedia = selectIsMedia(message);
    final isImage = isMedia && (message.msgtype == MatrixMessageTypes.image);

    // Styling variables
    var textColor = Colors.white;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    var bubbleColor = widget.color ?? AppColors.hashedColor(message.sender);
    final bubbleBorder = BorderRadius.circular(16);

    // Set colors based on theme and message type
    if (widget.isUserSent) {
      if (widget.themeType == ThemeType.Dark) {
        bubbleColor = const Color(AppColors.greyDark);
      } else if (widget.themeType != ThemeType.Light) {
        bubbleColor = const Color(AppColors.greyDarkest);
      } else {
        textColor = const Color(AppColors.blackFull);
        bubbleColor = const Color(AppColors.greyLightest);
      }
    } else {
      textColor = (widget.luminance ?? 0.0) > 0.6 ? Colors.black : Colors.white;
    }

    return GestureDetector(
      onTap: () {
        if (message.failed) {
          widget.onResend(message);
        }
      },
      onLongPress: () {
        if (widget.isUserSent) {
          showMenu(
            context: context,
            position: const RelativeRect.fromLTRB(100, 100, 100, 100),
            items: [
              PopupMenuItem(
                child: _buildContextMenu(),
                onTap: () {},
              ),
            ],
          );
        } else if (widget.onLongPress != null) {
          HapticFeedback.lightImpact();
          widget.onLongPress!(message);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 8.0,
        ),
        child: Row(
          mainAxisAlignment: widget.isUserSent ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!widget.isUserSent && showAvatar)
              Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 16.0),
                child: GestureDetector(
                  onTap: () => widget.onPressAvatar?.call(),
                  child: Avatar(
                    uri: widget.avatarUri,
                    alt: message.sender,
                    size: Dimensions.avatarSizeMessage,
                  ),
                ),
              ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: bubbleBorder,
                ),
                child: Column(
                  crossAxisAlignment: widget.isUserSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!widget.isUserSent)
                      Text(
                        widget.displayName ?? formatSender(message.sender!),
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: widget.messageSize,
                        ),
                      ),
                    MarkdownBody(
                      data: body,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: textColor,
                          fontSize: widget.fontSize,
                        ),
                        a: TextStyle(
                          color: Colors.blue[300],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    if (widget.isUserSent) _buildContextMenu(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenu() {
    final store = StoreProvider.of<AppState>(context);
    final user = store.state.authStore.user;
    final isOwnMessage = widget.message.senderId == user.userId;
    final canEdit = isOwnMessage && widget.message.msgtype == 'm.text';

    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'copy') {
          await Clipboard.setData(ClipboardData(text: widget.message.body ?? ''));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Message copied to clipboard')),
            );
          }
        } else if (value == 'edit') {
          final room = store.state.roomStore.rooms[widget.message.roomId];
          if (room != null) {
            final result = await showMessageEditDialog(
              context: context,
              message: widget.message,
              room: room,
            );

            if (result == true && widget.onEditMessage != null) {
              widget.onEditMessage!(widget.message);
            }
          }
        } else if (value == 'delete' && widget.onLongPress != null) {
          widget.onLongPress!(widget.message);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'copy',
          child: Text('Copy'),
        ),
        if (canEdit)
          const PopupMenuItem<String>(
            value: 'edit',
            child: Text('Edit'),
          ),
        if (isOwnMessage)
          const PopupMenuItem<String>(
            value: 'delete',
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
      ],
    );
  }
}
