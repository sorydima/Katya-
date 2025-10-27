import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/global/colors.dart';
import 'package:katya/global/strings.dart';
import 'package:katya/store/events/actions.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/store/events/selectors.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/rooms/room/model.dart';
import 'package:katya/store/settings/theme-settings/selectors.dart';
import 'package:katya/store/user/model.dart';
import 'package:katya/views/home/chat/chat-detail-message-screen.dart';
import 'package:katya/views/navigation.dart';
import 'package:share_plus/share_plus.dart';

class AppBarMessageOptions extends StatefulWidget implements PreferredSizeWidget {
  const AppBarMessageOptions({
    super.key,
    this.title = 'title:',
    this.label = 'label:',
    this.tooltip = 'tooltip:',
    this.room,
    this.message,
    this.brightness = Brightness.dark,
    this.elevation,
    this.focusNode,
    this.isUserSent = false,
    this.onCopy,
    this.onDelete,
    this.onReply,
    this.onEdit,
    this.onDismiss,
    required this.user,
  });

  final String title;
  final String label;
  final String tooltip;

  final Room? room;
  final User user;

  final bool isUserSent;

  final Message? message;
  final double? elevation;
  final Brightness brightness;
  final FocusNode? focusNode;

  final Function? onCopy;
  final Function? onEdit;
  final Function? onReply;
  final Function? onDelete;
  final Function? onDismiss;

  @override
  AppBarMessageOptionState createState() => AppBarMessageOptionState();

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class AppBarMessageOptionState extends State<AppBarMessageOptions> {
  final focusNode = FocusNode();

  bool searching = false;
  Timer? searchTimeout;

  @override
  void initState() {
    super.initState();
  }

  bool get isMessageDeleted => widget.message?.body?.isNotEmpty ?? true;

  @override
  Widget build(BuildContext context) => AppBar(
        systemOverlayStyle: computeSystemUIColor(context),
        backgroundColor: const Color(AppColors.greyDefault),
        automaticallyImplyLeading: false,
        titleSpacing: 0.0,
        title: Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                tooltip: Strings.labelBack,
                onPressed: () {
                  widget.onDismiss?.call();
                },
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info),
            tooltip: Strings.tooltipMessageDetails,
            color: Colors.white,
            onPressed: () {
              Navigator.pushNamed(
                context,
                Routes.messageDetails,
                arguments: MessageDetailArguments(
                  roomId: widget.room!.id,
                  message: widget.message,
                ),
              );

              widget.onDismiss?.call();
            },
          ),
          Visibility(
            visible: isMessageDeleted && widget.isUserSent,
            child: IconButton(
              icon: const Icon(Icons.delete),
              iconSize: 28.0,
              tooltip: Strings.tooltipDeleteMessage,
              color: Colors.white,
              onPressed: () {
                widget.onDelete?.call();
                widget.onDismiss?.call();
              },
            ),
          ),
          Visibility(
            visible: isMessageDeleted && widget.isUserSent,
            child: IconButton(
              icon: const Icon(Icons.edit_rounded),
              iconSize: 28.0,
              tooltip: Strings.tooltipEditMessage,
              color: Colors.white,
              onPressed: () {
                widget.onEdit?.call();
              },
            ),
          ),
          Visibility(
            visible: isTextMessage(
                message: widget.message ?? const Message(id: '', sender: '', timestamp: 0, type: '', roomId: '')),
            child: IconButton(
              icon: const Icon(Icons.content_copy),
              iconSize: 22.0,
              tooltip: Strings.tooltipCopyMessageContent,
              color: Colors.white,
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(
                    text: widget.message!.formattedBody ?? widget.message!.body ?? '',
                  ),
                );

                widget.onDismiss?.call();
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.reply),
            iconSize: 28.0,
            tooltip: Strings.tooltipQuoteAndReply,
            color: Colors.white,
            onPressed: () async {
              final store = StoreProvider.of<AppState>(context);
              final roomId = widget.message!.roomId!;

              store.dispatch(selectReply(roomId: roomId, message: widget.message));

              widget.onDismiss?.call();

              widget.onReply?.call();
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            iconSize: 24.0,
            tooltip: Strings.tooltipShareChats,
            color: Colors.white,
            onPressed: () {
              final room = widget.message!.roomId!;
              final message = widget.message!.id!;
              Share.share('https://matrix.to/#/$room/$message');
            },
          ),
        ],
      );
}
