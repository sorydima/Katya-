import 'dart:io';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:chewie/chewie.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:swipeable/swipeable.dart'; // Temporarily disabled for compatibility
import 'package:katya/global/colors.dart';
import 'package:katya/global/dimensions.dart';
import 'package:katya/global/formatters.dart';
import 'package:katya/global/libs/matrix/constants.dart';
import 'package:katya/global/noop.dart';
import 'package:katya/global/strings.dart';
import 'package:katya/global/weburl.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/store/events/messages/selectors.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/media/actions.dart';
import 'package:katya/store/settings/models.dart';
import 'package:katya/store/settings/theme-settings/model.dart';
import 'package:katya/views/home/chat/media-full-screen.dart';
import 'package:katya/views/widgets/avatars/avatar.dart';
import 'package:katya/views/widgets/dialogs/dialog-confirm.dart';
import 'package:katya/views/widgets/image-matrix.dart';
import 'package:katya/views/widgets/input/text-field-edit.dart';
import 'package:katya/views/widgets/messages/message_edit_dialog.dart';
import 'package:katya/views/widgets/messages/reaction-row.dart';
import 'package:katya/views/widgets/messages/styles.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:video_player/video_player.dart';

String? _firstUrl(String text) {
  final exp = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);
  final match = exp.firstMatch(text);
  return match?.group(0);
}

const MESSAGE_MARGIN_VERTICAL_LARGE = 6.0;
const MESSAGE_MARGIN_VERTICAL_NORMAL = 4.0;
const MESSAGE_MARGIN_VERTICAL_SMALL = 1.0;

class MessageWidget extends StatelessWidget {
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

  bool get mounted => true; // Add mounted getter for context safety

  final TextEditingController? editorController;

  final Function onSwipe;
  final Function onResend;
  final Function? onSendEdit;
  final Function? onLongPress;
  final Function? onPressAvatar;
  final Function? onInputReaction;
  final Function? onToggleReaction;
  final Function(Message)? onEditMessage;

  Widget _buildContextMenu() {
    final store = StoreProvider.of<AppState>(context);
    final user = store.state.authStore.user;
    final isOwnMessage = message.senderId == user.userId;
    final canEdit = isOwnMessage && message.msgtype == 'm.text';

    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'copy') {
          await Clipboard.setData(ClipboardData(text: message.body ?? ''));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Message copied to clipboard')),
            );
          }
        } else if (value == 'edit') {
          final room = store.state.roomStore.rooms[message.roomId];
          if (room != null) {
            final result = await showMessageEditDialog(
              context: context,
              message: message,
              room: room,
            );

            if (result == true && onEditMessage != null) {
              onEditMessage!(message);
            }
          }
        } else if (value == 'delete') {
          // Show delete confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Message'),
              content: const Text('Are you sure you want to delete this message?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );

          if (confirmed == true && onLongPress != null) {
            onLongPress!(message);
          }
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

  // Add build method to ensure the widget is properly built
  @override
  Widget build(BuildContext context) {
    return _buildMessageWidget(context);
  }

  Widget buildReactionsInput(
    BuildContext context,
    MainAxisAlignment alignment, {
    bool isUserSent = false,
  }) {
    final buildEmojiButton = GestureDetector(
      onTap: () => onInputReaction?.call(),
      child: ClipRRect(
        child: Container(
          width: 36,
          height: Dimensions.iconSizeLarge,
          decoration: BoxDecoration(
            color: const Color(AppColors.greyDefault),
            borderRadius: BorderRadius.circular(Dimensions.iconSizeLarge),
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.tag_faces,
            size: 22,
            color: Colors.white,
          ),
        ),
      ),
    );

    final reactionRow = ReactionRow(
      // key: Key(message.reactions.length.toString()),
      reactions: message.reactions,
    );

    // swaps order in row if user sent
    return Row(
      mainAxisAlignment: alignment,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: isUserSent ? [buildEmojiButton, reactionRow] : [reactionRow, buildEmojiButton],
    );
  }

  void onSwipeMessage(Message message) {
    onSwipe(message);
  }

  void onConfirmLink(BuildContext context, String? url) {
    showDialog(
      context: context,
      builder: (dialogContext) => DialogConfirm(
        title: Strings.titleDialogConfirmLinkout.capitalize(),
        content: Strings.confirmLinkout(url!),
        confirmStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
        confirmText: Strings.buttonConfirmFormal.capitalize(),
        onDismiss: () => Navigator.pop(dialogContext),
        onConfirm: () async {
          Navigator.of(dialogContext).pop();
          await launchUrl(url);
        },
      ),
    );
  }

  void onViewFullscreen(
    BuildContext context, {
    required Uint8List bytes,
    required String? eventId,
    required String? roomId,
    String filename = 'Katya ® 👽 AI 🧠 REChain 🪐 Blockchain Node Image',
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MediaFullScreen(
          title: filename,
          bytes: bytes,
          eventId: eventId,
          roomId: roomId,
        ),
      ),
    );
  }

  Widget _buildMessageWidget(BuildContext context) {
    final message = this.message;
    final selected = selectedMessageId != null && selectedMessageId == message.id;

    // emoji input button needs space
    final hasReactions = message.reactions.isNotEmpty || selected;
    final isRead = message.timestamp < lastRead;
    final showAvatar = !isLastSender && !isUserSent && !messageOnly;
    final body = selectEventBody(message);
    final isMedia = selectIsMedia(message);
    final isImage = isMedia && (message.msgtype == MatrixMessageTypes.image);
    final isAudio = isMedia && (message.msgtype == MatrixMessageTypes.audio);
    final isVideo = isMedia && (message.msgtype == MatrixMessageTypes.video);
    final isFile = isMedia && (message.msgtype == MatrixMessageTypes.file);
    final settings = StoreProvider.of<AppState>(context).state.settingsStore;
    final autoImg = settings.autoDownloadImages;
    final autoAud = settings.autoDownloadAudio;
    final autoVid = settings.autoDownloadVideo;
    final autoFil = settings.autoDownloadFiles;
    final removePadding = isMedia || (isEditing && selected);

    var textColor = Colors.white;
    Color anchorColor = Colors.blue;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    var showSender = !messageOnly && !isUserSent; // nearly always show the sender
    var luminance = this.luminance;

    var indicatorColor = Theme.of(context).iconTheme.color;
    var indicatorIconColor = Theme.of(context).iconTheme.color;
    var replyColor = color;
    var bubbleColor = color ?? AppColors.hashedColor(message.sender);
    var bubbleBorder = BorderRadius.circular(16);
    var alignmentMessage = MainAxisAlignment.start;
    var alignmentReaction = MainAxisAlignment.start;
    var alignmentMessageText = CrossAxisAlignment.start;
    var bubbleMargin = const EdgeInsets.symmetric(vertical: MESSAGE_MARGIN_VERTICAL_NORMAL);
    var showInfoRow = true;
    var showStatus = true;

    var fontStyle;
    var opacity = 1.0;
    var zIndex = 1.0;
    var status = timeFormat == TimeFormat.full
        ? formatTimestampFull(
            lastUpdateMillis: message.timestamp,
            timeFormat: timeFormat,
            showTime: true,
          )
        : formatTimestamp(
            lastUpdateMillis: message.timestamp,
            timeFormat: timeFormat,
            showTime: true,
          );

    // Current User Bubble Styling
    if (isUserSent) {
      if (isLastSender) {
        if (isNextSender) {
          // Message in the middle of a sender messages block
          bubbleMargin = const EdgeInsets.symmetric(vertical: MESSAGE_MARGIN_VERTICAL_SMALL);
          bubbleBorder = Styles.bubbleBorderMiddleUser;
          showInfoRow = isNewContext;
        } else {
          // Message at the beginning of a sender messages block
          bubbleMargin = const EdgeInsets.only(
            top: MESSAGE_MARGIN_VERTICAL_LARGE,
            bottom: MESSAGE_MARGIN_VERTICAL_SMALL,
          );
          bubbleBorder = Styles.bubbleBorderTopUser;
          showInfoRow = isNewContext;
        }
      }

      if (!isLastSender && isNextSender) {
        // End of a sender messages block
        bubbleMargin = const EdgeInsets.only(
          top: MESSAGE_MARGIN_VERTICAL_SMALL,
          bottom: MESSAGE_MARGIN_VERTICAL_LARGE,
        );
        bubbleBorder = Styles.bubbleBorderBottomUser;
      }
      // External User Sent Styling
    } else {
      if (isLastSender) {
        if (isNextSender) {
          // Message in the middle of a sender messages block
          bubbleMargin = const EdgeInsets.symmetric(vertical: MESSAGE_MARGIN_VERTICAL_SMALL);
          bubbleBorder = Styles.bubbleBorderMiddleSender;
          showSender = false;
          showInfoRow = isNewContext;
        } else {
          // Message at the beginning of a sender messages block
          bubbleMargin = const EdgeInsets.only(top: 8, bottom: MESSAGE_MARGIN_VERTICAL_SMALL);
          bubbleBorder = Styles.bubbleBorderTopSender;
          showInfoRow = isNewContext;
        }
      }

      if (!isLastSender && isNextSender) {
        // End of a sender messages block
        bubbleMargin = const EdgeInsets.only(
          top: MESSAGE_MARGIN_VERTICAL_SMALL,
          bottom: MESSAGE_MARGIN_VERTICAL_LARGE,
        );
        bubbleBorder = Styles.bubbleBorderBottomSender;
      }
    }

    if (isUserSent) {
      if (themeType == ThemeType.Dark) {
        bubbleColor = const Color(AppColors.greyDark);
        luminance = 0.2;
      } else if (themeType != ThemeType.Light) {
        bubbleColor = const Color(AppColors.greyDarkest);
        luminance = bubbleColor.computeLuminance();
        luminance = 0.2;
      } else {
        textColor = const Color(AppColors.blackFull);
        bubbleColor = const Color(AppColors.greyLightest);
        luminance = 0.85;
      }

      indicatorColor = isRead ? textColor : bubbleColor;
      indicatorIconColor = isRead ? bubbleColor : textColor;

      alignmentMessage = MainAxisAlignment.end;
      alignmentReaction = MainAxisAlignment.start;
      alignmentMessageText = CrossAxisAlignment.end;
    } else {
      textColor = (luminance ?? 0.0) > 0.6 ? Colors.black : Colors.white;
    }

    if (selectedMessageId != null && !selected) {
      opacity = 0.5;
      zIndex = -10.0;
    }

    if (message.failed) {
      status = Strings.alertMessageSendingFailed;
      showStatus = true;
      showInfoRow = true;
    }

    if (message.edited) {
      status += Strings.messageEditedAppend;
      showInfoRow = true;
    }

    // Indicates special event text instead of the message body
    if (message.body != body) {
      fontStyle = FontStyle.italic;
    }

    if (message.hasLink) {
      if (bubbleColor.delta(Colors.blue) > 0.85) {
        anchorColor = const Color(AppColors.blueDark);
      }
    }

    if (body.isNotEmpty && body[0] == '>') {
      final isLight = (luminance ?? 0.0) > 0.5;
      replyColor = HSLColor.fromColor(bubbleColor).withLightness(isLight ? 0.5 : 0.25).toColor();
    }

    return Container(
      child: GestureDetector(
        onTap: () {
          if (message.failed) {
            onResend(message);
          }
        },
        onLongPress: () {
          if (isUserSent) {
            showMenu(
              context: context,
              position: const RelativeRect.fromLTRB(100, 100, 100, 100), // Position doesn't matter, will be overridden
              items: [
                PopupMenuItem(
                  child: _buildContextMenu(),
                  onTap: () {},
                ),
              ],
            );
          } else if (onLongPress != null) {
            HapticFeedback.lightImpact();
            onLongPress!(message);
          }
        },
        child: Opacity(
          opacity: opacity,
          child: Container(
            transform: Matrix4.translationValues(0.0, 0.0, zIndex),
            child: Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: bubbleMargin, // spacing between different user bubbles
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: alignmentMessage,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Visibility(
                        visible: showAvatar,
                        maintainState: !messageOnly,
                        maintainAnimation: !messageOnly,
                        maintainSize: !messageOnly,
                        child: GestureDetector(
                          onTap: () {
                            if (onPressAvatar != null) {
                              HapticFeedback.lightImpact();
                              onPressAvatar!();
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8).copyWith(bottom: hasReactions ? 16 : 0),
                            child: Avatar(
                              margin: EdgeInsets.zero,
                              padding: EdgeInsets.zero,
                              uri: avatarUri,
                              alt: message.sender,
                              size: Dimensions.avatarSizeMessage,
                              background: AppColors.hashedColor(message.sender),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                // NOTE: issue shrinking the message based on width
                                maxWidth: !isMedia ? double.infinity : Dimensions.mediaSizeMaxMessage,
                                // NOTE: prevents exposing the reply icon
                                minWidth: 72,
                              ),
                              padding: EdgeInsets.only(
                                // make an image span the message width
                                left: removePadding ? 0 : 12,
                                // make an image span the message width
                                right: removePadding ? 0 : 12,
                                top: isMedia && !showSender ? 0 : 8,
                                // remove bottom padding if info row is hidden
                                bottom: isMedia
                                    ? 12
                                    : !showInfoRow
                                        ? 0
                                        : 8,
                              ),
                              margin: EdgeInsets.only(
                                bottom: hasReactions ? 18 : 0,
                              ),
                              decoration: BoxDecoration(
                                color: bubbleColor,
                                borderRadius: bubbleBorder,
                              ),
                              child: Flex(
                                direction: Axis.vertical,
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: alignmentMessageText,
                                children: <Widget>[
                                  Visibility(
                                    visible: showSender,
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        bottom: 4,
                                        left: isMedia ? 12 : 0,
                                        right: isMedia ? 12 : 0,
                                      ), // make an image span the message width
                                      child: Text(
                                        displayName ?? formatSender(message.sender!),
                                        style: TextStyle(
                                          fontSize: messageSize,
                                          color: textColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: isMedia,
                                    maintainState: false,
                                    child: Builder(
                                      builder: (_) {
                                        if (isImage) {
                                          return ClipRRect(
                                            borderRadius: showSender
                                                ? BorderRadius.zero
                                                : BorderRadius.only(
                                                    topLeft: bubbleBorder.topLeft,
                                                    topRight: bubbleBorder.topRight,
                                                  ),
                                            child: MatrixImage(
                                              fileName: body,
                                              mxcUri: message.url,
                                              thumbnail: false,
                                              autodownload: autoImg,
                                              fit: BoxFit.cover,
                                              rebuild: true,
                                              onPressImage: (Uint8List bytes) => onViewFullscreen(context,
                                                  filename: body,
                                                  bytes: bytes,
                                                  eventId: message.id,
                                                  roomId: message.roomId),
                                              width: Dimensions.mediaSizeMaxMessage,
                                              height: Dimensions.mediaSizeMaxMessage,
                                              fallbackColor: Colors.transparent,
                                              loadingPadding: 32,
                                            ),
                                          );
                                        }

                                        Future<void> openMxc(String? mxcUri, String? filename) async {
                                          if (mxcUri == null) return;
                                          final store = StoreProvider.of<AppState>(context);
                                          var data = store.state.mediaStore.mediaCache[mxcUri];
                                          if (data == null) {
                                            await store.dispatch(fetchMedia(mxcUri: mxcUri));
                                            data = store.state.mediaStore.mediaCache[mxcUri];
                                          }
                                          if (data == null) return;
                                          final dir = await getTemporaryDirectory();
                                          final safeName = (filename == null || filename.isEmpty) ? 'media' : filename;
                                          final filePath = path.join(dir.path, safeName);
                                          final file = File(filePath);
                                          await file.writeAsBytes(data, flush: true);
                                          await OpenFilex.open(file.path);
                                        }

                                        if (isAudio) {
                                          return _InlineAudioPlayer(
                                            mxcUri: message.url,
                                            filename: body,
                                            textColor: textColor,
                                            autoload: autoAud,
                                          );
                                        }
                                        if (isVideo) {
                                          return _InlineVideoPlayer(
                                            mxcUri: message.url,
                                            filename: body,
                                            autoload: autoVid,
                                          );
                                        }
                                        const icon = Icons.insert_drive_file;
                                        final label = body.isNotEmpty ? body : 'File';
                                        final isPdf = (message.info?['mimetype'] ?? '').toString().contains('pdf') ||
                                            (body.toLowerCase().endsWith('.pdf'));
                                        if (!autoFil) {
                                          return ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Icon(icon, color: textColor),
                                            title: Text(
                                              label,
                                              style: TextStyle(color: textColor, fontSize: messageSize),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            trailing: TextButton(
                                              onPressed: () => openMxc(message.url, body),
                                              child: const Text('Download'),
                                            ),
                                          );
                                        }
                                        if (isPdf) {
                                          return _InlinePdfViewer(mxcUri: message.url, filename: body);
                                        }
                                        return ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: Icon(icon, color: textColor),
                                          title: Text(
                                            label,
                                            style: TextStyle(color: textColor, fontSize: messageSize),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          onTap: () => openMxc(message.url, body),
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                      bottom: 6,
                                      top: isMedia ? 8 : 0,
                                      left: isMedia ? 12 : 0,
                                      right: isMedia ? 12 : 0,
                                    ),
                                    child: AnimatedCrossFade(
                                      duration: const Duration(milliseconds: 150),
                                      crossFadeState:
                                          isEditing && selected ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                      firstChild: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          MarkdownBody(
                                            data: body.trim(),
                                            softLineBreak: true,
                                            onTapLink: (text, href, title) => onConfirmLink(context, href),
                                            styleSheet: MarkdownStyleSheet(
                                              a: TextStyle(color: anchorColor),
                                              blockquote: TextStyle(
                                                backgroundColor: bubbleColor,
                                              ),
                                              blockquoteDecoration: BoxDecoration(
                                                color: replyColor,
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(12),
                                                  bottomLeft: Radius.circular(12),
                                                  bottomRight: Radius.circular(12),
                                                ),
                                              ),
                                              p: TextStyle(
                                                color: textColor,
                                                fontStyle: fontStyle,
                                                fontWeight: FontWeight.w300,
                                                fontSize: messageSize,
                                              ),
                                              codeblockDecoration: ShapeDecoration(
                                                color: backgroundColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (message.hasLink)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 6),
                                              child: AnyLinkPreview(
                                                link: _firstUrl(body),
                                                displayDirection: UIDirection.uiDirectionHorizontal,
                                                bodyMaxLines: 2,
                                                bodyTextOverflow: TextOverflow.ellipsis,
                                                titleStyle: TextStyle(fontSize: messageSize, color: textColor),
                                                bodyStyle:
                                                    TextStyle(fontSize: messageSize, color: textColor.withOpacity(0.9)),
                                                backgroundColor: bubbleColor,
                                                borderRadius: 12,
                                                errorBody: '',
                                                errorTitle: '',
                                                errorWidget: const SizedBox.shrink(),
                                                cache: const Duration(hours: 24),
                                              ),
                                            ),
                                        ],
                                      ),
                                      // HACK: to prevent other instantiations overwriting editorController
                                      secondChild: !selected
                                          ? Container()
                                          : Padding(
                                              padding: const EdgeInsets.only(left: 12, right: 12),
                                              child: IntrinsicWidth(
                                                child: TextFieldInline(
                                                  body: body,
                                                  autofocus: isEditing,
                                                  controller: editorController,
                                                  onEdit: (text) => onSendEdit!(text, message),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: showInfoRow,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: removePadding ? 12 : 0,
                                      ),
                                      child: Flex(
                                        /// *** Message Status Row ***
                                        direction: Axis.horizontal,
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: alignmentMessageText,
                                        children: [
                                          Visibility(
                                            visible: !isUserSent && message.type == EventTypes.encrypted,
                                            child: Container(
                                              width: Dimensions.indicatorSize,
                                              height: Dimensions.indicatorSize,
                                              margin: const EdgeInsets.only(right: 4),
                                              child: Icon(
                                                Icons.lock,
                                                color: textColor,
                                                size: Dimensions.iconSizeMini,
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: showStatus,
                                            child: Container(
                                              // timestamp and error message
                                              margin: const EdgeInsets.only(right: 4),
                                              child: Text(
                                                status,
                                                style: TextStyle(
                                                  fontSize: messageSize,
                                                  color: textColor,
                                                  fontWeight: FontWeight.w100,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: isUserSent && message.type == EventTypes.encrypted,
                                            child: Container(
                                              width: Dimensions.indicatorSize,
                                              height: Dimensions.indicatorSize,
                                              margin: const EdgeInsets.only(left: 2),
                                              child: Icon(
                                                Icons.lock,
                                                color: textColor,
                                                size: Dimensions.iconSizeMini,
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: isUserSent && message.failed,
                                            child: Container(
                                              width: Dimensions.indicatorSize,
                                              height: Dimensions.indicatorSize,
                                              margin: const EdgeInsets.only(left: 3),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.redAccent,
                                                size: Dimensions.indicatorSize,
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: isUserSent && !message.failed,
                                            child: Stack(
                                              children: [
                                                Visibility(
                                                  visible: message.pending,
                                                  child: Container(
                                                    width: Dimensions.indicatorSize,
                                                    height: Dimensions.indicatorSize,
                                                    margin: const EdgeInsets.only(left: 4),
                                                    child: const CircularProgressIndicator(
                                                      strokeWidth: Dimensions.strokeWidthThin,
                                                    ),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: !message.pending,
                                                  child: Container(
                                                    width: Dimensions.indicatorSize,
                                                    height: Dimensions.indicatorSize,
                                                    margin: const EdgeInsets.only(left: 4),
                                                    decoration: ShapeDecoration(
                                                      color: indicatorColor,
                                                      shape: CircleBorder(
                                                        side: BorderSide(
                                                          color: indicatorIconColor!,
                                                          width: isRead ? 1.5 : 1,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.check,
                                                      size: 10,
                                                      color: indicatorIconColor,
                                                    ),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: !message.syncing,
                                                  child: Container(
                                                    width: Dimensions.indicatorSize,
                                                    height: Dimensions.indicatorSize,
                                                    margin: const EdgeInsets.only(left: 11),
                                                    decoration: ShapeDecoration(
                                                      color: indicatorColor,
                                                      shape: CircleBorder(
                                                        side: BorderSide(
                                                          color: indicatorIconColor,
                                                          width: isRead ? 1.5 : 1,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.check,
                                                      size: 10,
                                                      color: indicatorIconColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: selected,
                              child: Positioned(
                                left: isUserSent ? 0 : null,
                                right: !isUserSent ? 0 : null,
                                bottom: 0,
                                child: Container(
                                  height: Dimensions.iconSize,
                                  transform: Matrix4.translationValues(0.0, 4.0, 0.0),
                                  child: buildReactionsInput(
                                    context,
                                    alignmentReaction,
                                    isUserSent: isUserSent,
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: hasReactions && !selected,
                              child: Positioned(
                                left: isUserSent ? 0 : null,
                                right: !isUserSent ? 0 : null,
                                bottom: 0,
                                child: Container(
                                  height: Dimensions.iconSize,
                                  transform: Matrix4.translationValues(0.0, 4.0, 0.0),
                                  child: ReactionRow(
                                    key: Key(message.reactions.length.toString()),
                                    reactions: message.reactions,
                                    onToggleReaction: onToggleReaction,
                                    onEditMessage: onEditMessage,
                                  ),
                                ),
                              ),
                            ),
                            if (isUserSent)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: _buildContextMenu(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContextMenu() {
    final store = StoreProvider.of<AppState>(context);
    final user = store.state.authStore.user;
    final isOwnMessage = message.senderId == user.userId;
    final canEdit = isOwnMessage && message.msgtype == 'm.text';

    return PopupMenuButton<dynamic>(
      onSelected: (dynamic value) async {
        if (value == 'copy') {
          Clipboard.setData(ClipboardData(text: message.body ?? ''));
        } else if (value == 'edit') {
          final room = store.state.roomStore.rooms[message.roomId];
          if (room != null) {
            final result = await showMessageEditDialog(
              context: context,
              message: message,
              room: room,
            );

            if (result == true && onEditMessage != null) {
              onEditMessage!(message);
            }
          }
        } else if (value == 'reply') {
          // Handle reply
        } else if (value == 'react') {
          // Handle reaction
        } else if (value == 'delete') {
          // Handle delete
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        const PopupMenuItem(
          value: 'copy',
          child: Text('Copy'),
        ),
        if (canEdit)
          const PopupMenuItem(
            value: 'edit',
            child: Text('Edit'),
          ),
        const PopupMenuItem(
          value: 'reply',
          child: Text('Reply'),
        ),
        const PopupMenuItem(
          value: 'react',
          child: Text('React'),
        ),
        if (isOwnMessage)
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          ),
      ],
    );
  }
}

class _InlineAudioPlayer extends StatefulWidget {
  final String? mxcUri;
  final String? filename;
  final Color textColor;
  final bool autoload;
  const _InlineAudioPlayer(
      {required this.mxcUri, required this.filename, required this.textColor, this.autoload = true});
  @override
  State<_InlineAudioPlayer> createState() => _InlineAudioPlayerState();
}

class _InlineAudioPlayerState extends State<_InlineAudioPlayer> {
  late AudioPlayer _player;
  String? _localPath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _prepare();
  }

  Future<void> _prepare() async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    var data = store.state.mediaStore.mediaCache[widget.mxcUri];
    if (data == null && widget.autoload) {
      await store.dispatch(fetchMedia(mxcUri: widget.mxcUri));
      data = store.state.mediaStore.mediaCache[widget.mxcUri];
    }
    if (data == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    final dir = await getTemporaryDirectory();
    final safeName = (widget.filename == null || widget.filename!.isEmpty) ? 'audio.m4a' : widget.filename!;
    final filePath = path.join(dir.path, safeName);
    final file = File(filePath);
    await file.writeAsBytes(data, flush: true);
    _localPath = file.path;
    await _player.setFilePath(_localPath!);
    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.autoload)
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 8),
            Text(widget.filename ?? 'Audio', style: TextStyle(color: widget.textColor)),
            if (!widget.autoload)
              TextButton(
                onPressed: _prepare,
                child: Text('Load', style: TextStyle(color: widget.textColor)),
              )
          ],
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snapshot) {
            final playing = snapshot.data?.playing ?? false;
            return IconButton(
              icon: Icon(playing ? Icons.pause_circle : Icons.play_circle, color: widget.textColor),
              onPressed: () => playing ? _player.pause() : _player.play(),
            );
          },
        ),
        Expanded(
          child: StreamBuilder<Duration?>(
            stream: _player.durationStream,
            builder: (context, snapshot) {
              final duration = snapshot.data ?? Duration.zero;
              return StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, posSnap) {
                  final position = posSnap.data ?? Duration.zero;
                  final value = duration.inMilliseconds == 0 ? 0.0 : position.inMilliseconds / duration.inMilliseconds;
                  return Slider(
                    value: value.clamp(0.0, 1.0),
                    onChanged: (v) {
                      final newPos = duration * v;
                      _player.seek(newPos);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InlineVideoPlayer extends StatefulWidget {
  final String? mxcUri;
  final String? filename;
  final bool autoload;
  const _InlineVideoPlayer({required this.mxcUri, required this.filename, this.autoload = true});
  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> {
  VideoPlayerController? _controller;
  ChewieController? _chewie;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    var data = store.state.mediaStore.mediaCache[widget.mxcUri];
    if (data == null && widget.autoload) {
      await store.dispatch(fetchMedia(mxcUri: widget.mxcUri));
      data = store.state.mediaStore.mediaCache[widget.mxcUri];
    }
    if (data == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    final dir = await getTemporaryDirectory();
    final safeName = (widget.filename == null || widget.filename!.isEmpty) ? 'video.mp4' : widget.filename!;
    final filePath = path.join(dir.path, safeName);
    final file = File(filePath);
    await file.writeAsBytes(data, flush: true);

    _controller = VideoPlayerController.file(file);
    await _controller!.initialize();
    _chewie = ChewieController(videoPlayerController: _controller!, autoInitialize: true);
    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _chewie?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: widget.autoload
            ? const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 2))
            : TextButton(onPressed: _prepare, child: const Text('Load')),
      );
    }
    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: Chewie(controller: _chewie!),
    );
  }
}

class _InlinePdfViewer extends StatefulWidget {
  final String? mxcUri;
  final String filename;
  const _InlinePdfViewer({required this.mxcUri, required this.filename});
  @override
  State<_InlinePdfViewer> createState() => _InlinePdfViewerState();
}

class _InlinePdfViewerState extends State<_InlinePdfViewer> {
  PdfController? _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    var data = store.state.mediaStore.mediaCache[widget.mxcUri];
    if (data == null) {
      await store.dispatch(fetchMedia(mxcUri: widget.mxcUri));
      data = store.state.mediaStore.mediaCache[widget.mxcUri];
    }
    if (data == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    final dir = await getTemporaryDirectory();
    final filePath = path.join(dir.path, widget.filename.isEmpty ? 'document.pdf' : widget.filename);
    final file = File(filePath);
    await file.writeAsBytes(data, flush: true);
    _controller = PdfController(document: PdfDocument.openFile(file.path));
    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _controller == null) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return SizedBox(
      height: 240,
      child: PdfView(
        controller: _controller!,
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
      ),
    );
  }
}
