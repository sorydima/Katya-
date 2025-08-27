import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux/flutter_redux.dart';
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
import 'package:katya/store/settings/models.dart';
import 'package:katya/store/settings/theme-settings/model.dart';
import 'package:katya/views/home/chat/media-full-screen.dart';
import 'package:katya/views/widgets/avatars/avatar.dart';
import 'package:katya/views/widgets/dialogs/dialog-confirm.dart';
import 'package:katya/views/widgets/image-matrix.dart';
import 'package:katya/views/widgets/input/text-field-edit.dart';
import 'package:katya/views/widgets/messages/reaction-row.dart';
import 'package:katya/views/widgets/messages/styles.dart';

const MESSAGE_MARGIN_VERTICAL_LARGE = 6.0;
const MESSAGE_MARGIN_VERTICAL_NORMAL = 4.0;
const MESSAGE_MARGIN_VERTICAL_SMALL = 1.0;

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    Key? key,
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
  }) : super(key: key);

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
  final Function? onPressAvatar;
  final Function? onInputReaction;
  final Function? onToggleReaction;
  final void Function(Message)? onLongPress;

  buildReactionsInput(
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
            color: Color(AppColors.greyDefault),
            borderRadius: BorderRadius.circular(Dimensions.iconSizeLarge),
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
          ),
          child: Icon(
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

  onSwipeMessage(Message message) {
    onSwipe(message);
  }

  onConfirmLink(BuildContext context, String? url) {
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

  onViewFullscreen(
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

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    final selected = selectedMessageId != null && selectedMessageId == message.id;

    // emoji input button needs space
    final hasReactions = message.reactions.isNotEmpty || selected;
    final isRead = message.timestamp < lastRead;
    final showAvatar = !isLastSender && !isUserSent && !messageOnly;
    final body = selectEventBody(message);
    final isMedia = selectIsMedia(message);
    final removePadding = isMedia || (isEditing && selected);

    var textColor = Colors.white;
    Color anchorColor = Colors.blue;
    var backgroundColor = Theme.of(context).scaffoldBackgroundColor;
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
          bubbleMargin = EdgeInsets.symmetric(vertical: MESSAGE_MARGIN_VERTICAL_SMALL);
          bubbleBorder = Styles.bubbleBorderMiddleUser;
          showInfoRow = isNewContext;
        } else {
          // Message at the beginning of a user sender messages block
          bubbleMargin = EdgeInsets.only(
            top: MESSAGE_MARGIN_VERTICAL_LARGE,
            bottom: MESSAGE_MARGIN_VERTICAL_SMALL,
          );
          bubbleBorder = Styles.bubbleBorderTopUser;
          showInfoRow = isNewContext;
        }
      }

      if (!isLastSender && isNextSender) {
        // End of a sender messages block
        bubbleMargin = EdgeInsets.only(
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
          bubbleMargin = EdgeInsets.symmetric(vertical: MESSAGE_MARGIN_VERTICAL_SMALL);
          bubbleBorder = Styles.bubbleBorderMiddleSender;
          showSender = false;
          showInfoRow = isNewContext;
        } else {
          // Message at the beginning of a sender messages block
          bubbleMargin = EdgeInsets.only(top: 8, bottom: MESSAGE_MARGIN_VERTICAL_SMALL);
          bubbleBorder = Styles.bubbleBorderTopSender;
          showInfoRow = isNewContext;
        }
      }

      if (!isLastSender && isNextSender) {
        // End of a sender messages block
        bubbleMargin = EdgeInsets.only(
          top: MESSAGE_MARGIN_VERTICAL_SMALL,
          bottom: MESSAGE_MARGIN_VERTICAL_LARGE,
        );
        bubbleBorder = Styles.bubbleBorderBottomSender;
      }
    }

    if (isUserSent) {
      if (themeType == ThemeType.Dark) {
        bubbleColor = Color(AppColors.greyDark);
        luminance = 0.2;
      } else if (themeType != ThemeType.Light) {
        bubbleColor = Color(AppColors.greyDarkest);
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
        anchorColor = Color(AppColors.blueDark);
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
          if (onLongPress != null) {
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
                            margin: const EdgeInsets.only(right: 8)
                                .copyWith(bottom: hasReactions ? 16 : 0),
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
                                maxWidth:
                                    !isMedia ? double.infinity : Dimensions.mediaSizeMaxMessage,
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
                                    child: ClipRRect(
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
                                        autodownload: StoreProvider.of<AppState>(context)
                                            .state
                                            .settingsStore
                                            .autoDownloadEnabled,
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
                                      crossFadeState: isEditing && selected
                                          ? CrossFadeState.showSecond
                                          : CrossFadeState.showFirst,
                                      firstChild: MarkdownBody(
                                        data: body.trim(),
                                        softLineBreak: true,
                                        onTapLink: (text, href, title) =>
                                            onConfirmLink(context, href),
                                        styleSheet: MarkdownStyleSheet(
                                          a: TextStyle(color: anchorColor),
                                          blockquote: TextStyle(
                                            backgroundColor: bubbleColor,
                                          ),
                                          blockquoteDecoration: BoxDecoration(
                                            color: replyColor,
                                            borderRadius: const BorderRadius.only(
                                              //TODO: shape similar to bubbleBorder
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
                                      // HACK: to prevent other instantiations overwriting editorController
                                      secondChild: !selected
                                          ? Container()
                                          : Padding(
                                              padding: EdgeInsets.only(left: 12, right: 12),
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
                                            visible:
                                                !isUserSent && message.type == EventTypes.encrypted,
                                            child: Container(
                                              width: Dimensions.indicatorSize,
                                              height: Dimensions.indicatorSize,
                                              margin: EdgeInsets.only(right: 4),
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
                                              margin: EdgeInsets.only(right: 4),
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
                                            visible:
                                                isUserSent && message.type == EventTypes.encrypted,
                                            child: Container(
                                              width: Dimensions.indicatorSize,
                                              height: Dimensions.indicatorSize,
                                              margin: EdgeInsets.only(left: 2),
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
                                              margin: EdgeInsets.only(left: 3),
                                              child: Icon(
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
                                                    margin: EdgeInsets.only(left: 4),
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: Dimensions.strokeWidthThin,
                                                    ),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: !message.pending,
                                                  child: Container(
                                                    width: Dimensions.indicatorSize,
                                                    height: Dimensions.indicatorSize,
                                                    margin: EdgeInsets.only(left: 4),
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
                                                    margin: EdgeInsets.only(left: 11),
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
                                  ),
                                ),
                              ),
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
}
