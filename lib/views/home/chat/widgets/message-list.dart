import 'dart:async';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/global/colors.dart';
import 'package:katya/global/print.dart';
import 'package:katya/providers/web3_provider.dart';
import 'package:katya/services/nft_avatar_service.dart';
import 'package:katya/services/token_gate_service.dart';
import 'package:katya/store/events/actions.dart';
import 'package:katya/store/events/messages/actions.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/store/events/messages/selectors.dart';
import 'package:katya/store/events/reactions/actions.dart';
import 'package:katya/store/events/selectors.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/rooms/room/model.dart';
import 'package:katya/store/rooms/selectors.dart';
import 'package:katya/store/settings/chat-settings/selectors.dart';
import 'package:katya/store/settings/models.dart';
import 'package:katya/store/settings/theme-settings/model.dart';
import 'package:katya/store/settings/theme-settings/selectors.dart';
import 'package:katya/store/user/model.dart';
import 'package:katya/store/user/selectors.dart';
import 'package:katya/views/widgets/avatars/nft_avatar.dart';
import 'package:katya/views/widgets/encryption_indicator.dart';
import 'package:katya/views/widgets/lifecycle.dart';
import 'package:katya/views/widgets/message_item.dart';
import 'package:katya/views/widgets/messages/editable_message.dart';
import 'package:katya/views/widgets/messages/message_widget.dart';
import 'package:katya/views/widgets/messages/typing-indicator.dart';
import 'package:katya/views/widgets/token_gate/token_gate_widget.dart';
import 'package:provider/provider.dart';
import 'package:redux/redux.dart';

class MessageList extends StatefulWidget {
  final String roomId;

  final bool editing;
  final bool showAvatars;
  final Message? selectedMessage;
  final TextEditingController editorController;

  final ScrollController scrollController;

  final Function? onSendEdit;
  final Function? onSelectReply;
  final void Function({Message? message, User? user, String? userId})? onViewUserDetails;
  final void Function(Message?)? onToggleSelectedMessage;

  const MessageList({
    super.key,
    required this.roomId,
    required this.scrollController,
    required this.editorController,
    this.showAvatars = true,
    this.editing = false,
    this.selectedMessage,
    this.onSendEdit,
    this.onSelectReply,
    this.onViewUserDetails,
    this.onToggleSelectedMessage,
  });

  @override
  MessageListState createState() => MessageListState();
}

class MessageListState extends State<MessageList> with Lifecycle<MessageList> {
  late final TokenGateService _tokenGateService;
  final Map<String, bool> _messageAccessCache = {};
  final Map<String, StreamSubscription> _subscriptions = {};
  final TextEditingController controller = TextEditingController();

  final Map<String, Color> colorMap = {};
  final Map<String, double> luminanceMap = {};
  final Map<String, dynamic> _nftAvatars = {};
  final Map<String, String> _ensNames = {};
  final NftAvatarService _nftAvatarService = NftAvatarService();
  StreamSubscription? _nftSubscription;

  @override
  Future<void> onMounted() async {
    final store = StoreProvider.of<AppState>(context);
    final messages = roomMessages(store.state, widget.roomId);
    final web3Provider = context.read<Web3Provider>();

    // Initialize token gate service
    _tokenGateService = await getTokenGateService();

    setState(() {
      for (final message in messages) {
        final sender = message.sender ?? '';
        final userColor = AppColors.hashedColor(sender);
        colorMap[sender] = userColor;
        luminanceMap[sender] = userColor.computeLuminance();

        // Load NFT avatars and ENS names in the background
        _loadNftAvatar(sender);
        _resolveEnsName(sender, web3Provider);

        // Check message access in the background
        _checkMessageAccess(message);
      }
    });

    // Listen for new messages
    _nftSubscription = _nftAvatarService.avatarStream.listen((event) {
      if (mounted && event != null && event['address'] != null) {
        setState(() {
          _nftAvatars[event['address']] = event;
        });
      }
    });
  }

  @override
  void dispose() {
    _nftSubscription?.cancel();
    // Cancel all subscriptions
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }

  Future<void> _loadNftAvatar(String address) async {
    if (_nftAvatars.containsKey(address)) return;

    try {
      final nftData = await _nftAvatarService.getNftAvatar(address);
      if (nftData != null && mounted) {
        setState(() {
          _nftAvatars[address] = nftData;
        });
      }
    } catch (e) {
      log.error('Error loading NFT avatar for $address: $e');
    }
  }

  Future<void> _resolveEnsName(String address, Web3Provider web3Provider) async {
    if (_ensNames.containsKey(address)) return;

    try {
      final ensName = await web3Provider.resolveEnsName(address);
      if (ensName != null && mounted) {
        setState(() {
          _ensNames[address] = ensName;
        });
      }
    } catch (e) {
      log.error('Error resolving ENS name for $address: $e');
    }
  }

  void onSelectReply(Message? message) {
    final store = StoreProvider.of<AppState>(context);
    final roomId = widget.roomId;

    try {
      store.dispatch(selectReply(roomId: roomId, message: message));
    } catch (error) {
      log.error(error.toString());
    }
  }

  // Check if user has access to a token-gated message
  Future<bool> _checkMessageAccess(Message message) async {
    if (message.tokenGateConfig == null) return true;

    final cacheKey = '${message.id}-${message.sender}';

    // Cancel any existing subscription for this message
    _subscriptions[cacheKey]?.cancel();

    final completer = Completer<bool>();

    // Check access in the background
    _subscriptions[cacheKey] = Stream.fromFuture(
      _tokenGateService.checkTokenAccess(
        address: message.sender ?? '',
        config: message.tokenGateConfig ?? {},
      ),
    ).listen((hasAccess) {
      if (mounted) {
        setState(() {
          _messageAccessCache[cacheKey] = hasAccess;
        });
      }
      completer.complete(hasAccess);
    });

    return _messageAccessCache[cacheKey] ?? await completer.future;
  }

  // Get cached access state for a message
  bool _getCachedMessageAccess(Message message) {
    final cacheKey = '${message.id}-${message.sender}';
    return _messageAccessCache[cacheKey] ?? false;
  }

  Future<void> onResendMessage(Message message) async {
    final store = StoreProvider.of<AppState>(context);
    final roomId = widget.roomId;

    try {
      // Check if message is token-gated and user has access
      if (message.tokenGateConfig != null) {
        final hasAccess = await _checkMessageAccess(message);
        if (!hasAccess) {
          // Show access denied message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You need to meet the token requirements to resend this message'),
            ),
          );
          return;
        }
      }

      store.dispatch(sendMessageExisting(roomId: roomId, message: message));
    } catch (error) {
      log.error(error.toString());
    }
  }

  void onToggleReaction({Message? message, String? emoji}) {
    final store = StoreProvider.of<AppState>(context);
    final roomId = widget.roomId;
    final room = selectRoom(id: roomId, state: store.state);

    store.dispatch(
      toggleReaction(room: room, message: message, emoji: emoji),
    );
  }

  Future<void> onInputReaction({Message? message, _Props? props}) async {
    final height = MediaQuery.of(context).size.height;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: height / 2.2,
        padding: const EdgeInsets.symmetric(
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: EmojiPicker(
            config: const Config(),
            onEmojiSelected: (category, emoji) {
              onToggleReaction(
                emoji: emoji.emoji,
                message: message,
              );

              Navigator.pop(context, false);
              widget.onToggleSelectedMessage!(null);
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _Props>(
      converter: (Store<AppState> store) => _Props.mapStateToProps(store, widget.roomId),
      builder: (context, props) {
        final messages = props.messages;
        final room = props.room;
        final currentUser = props.currentUser;
        final chatSettings = props.chatSettings;
        final theme = props.theme;
        final isDark = theme.brightness == Brightness.dark;
        final web3Provider = context.watch<Web3Provider>();
        final currentAddress = web3Provider.ethereumAddress?.hex;

        if (messages.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No messages yet. Say hello! 👋',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildEncryptionStatus(context, props),
            Expanded(
              child: ListView.builder(
                controller: widget.scrollController,
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: props.messages.length + 1, // +1 for typing indicator
                itemBuilder: (BuildContext context, int index) {
                  // Show typing indicator at the bottom
                  if (index >= props.messages.length) {
                    return TypingIndicator(roomId: widget.roomId);
                  }

                  final message = props.messages[index];
                  final isOwnMessage = message.senderId == props.currentUserId;
                  final showAvatar = widget.showAvatars && !isOwnMessage;
                  final showTimestamp = index == 0 ||
                      props.messages[index - 1].originServerTs.difference(message.originServerTs).inMinutes > 5;
                  final isEncrypted = props.room.encrypted ?? false;

                  return Column(
                    children: [
                      if (showTimestamp && isEncrypted && index == 0)
                        _buildEncryptionNotice(context, isEncrypted, props.room),
                      MessageWidget(
                        message: message,
                        isOwnMessage: isOwnMessage,
                        showAvatar: showAvatar,
                        showTimestamp: showTimestamp,
                        isEditing: widget.editing && widget.selectedMessage?.eventId == message.eventId,
                        onSelectReply: widget.onSelectReply,
                        onViewUserDetails: widget.onViewUserDetails,
                        onToggleSelected: widget.onToggleSelectedMessage,
                        showEncryptionStatus: isEncrypted,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEncryptionStatus(BuildContext context, _Props props) {
    final isEncrypted = props.room.encrypted ?? false;

    if (!isEncrypted) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          const Text('End-to-end encrypted', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.info_outline, size: 16),
            onPressed: () => _showEncryptionInfo(context, props.room),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEncryptionNotice(BuildContext context, bool isEncrypted, Room? room) {
    if (!isEncrypted) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            'Messages in this chat are end-to-end encrypted',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  void _showEncryptionInfo(BuildContext context, Room? room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End-to-end Encryption'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Messages in this chat are end-to-end encrypted. This means that only you and the recipient can read them.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (room?.encryptionAlgorithm != null) _buildInfoRow('Encryption', room!.encryptionAlgorithm!),
            if (room?.verificationState != null) _buildInfoRow('Verification', room!.verificationState!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('GOT IT'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _Props extends Equatable {
  final Room room;
  final User currentUser;
  final ThemeType themeType;
  final MessageSize messageSize;
  final TimeFormat timeFormat;
  final Map<String, User> users;
  final List<Message> messages;
  final List<Message> messagesRaw;
  final Color? chatColorPrimary;
  final bool isEncrypted;

  const _Props({
    required this.room,
    required this.themeType,
    required this.messageSize,
    required this.users,
    required this.messages,
    required this.messagesRaw,
    required this.currentUser,
    required this.timeFormat,
    required this.chatColorPrimary,
    required this.isEncrypted,
  });

  @override
  List<Object> get props => [
        room,
        users,
        messagesRaw,
      ];

  static _Props mapStateToProps(Store<AppState> store, String roomId) => _Props(
        timeFormat: store.state.settingsStore.timeFormat24Enabled ? TimeFormat.hr24 : TimeFormat.hr12,
        themeType: store.state.settingsStore.themeSettings.themeType,
        messageSize: store.state.settingsStore.themeSettings.messageSize,
        currentUser: store.state.authStore.user,
        chatColorPrimary: selectBubbleColor(store, roomId),
        room: selectRoom(store.state, roomId),
        users: messageUsers(roomId: roomId, state: store.state),
        messagesRaw: roomMessages(store.state, roomId),
        messages: latestMessages(
          filterMessages(
            combineOutbox(
              outbox: roomOutbox(store.state, roomId),
              messages: roomMessages(store.state, roomId),
            ),
            store.state,
          ),
        ),
      );
}
