import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/svg.dart';
import 'package:redux/redux.dart';
import 'package:katya/global/assets.dart';
import 'package:katya/global/colors.dart';
import 'package:katya/global/dimensions.dart';
import 'package:katya/global/strings.dart';
import 'package:katya/store/alerts/actions.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/rooms/actions.dart';
import 'package:katya/store/rooms/selectors.dart';
import 'package:katya/store/user/actions.dart';
import 'package:katya/store/user/model.dart';
import 'package:katya/views/home/chat/chat-screen.dart';
import 'package:katya/views/home/profile/profile-user-screen.dart';
import 'package:katya/views/home/search/search-chats-screen.dart';
import 'package:katya/views/navigation.dart';
import 'package:katya/views/widgets/avatars/avatar.dart';
import 'package:katya/views/widgets/dialogs/dialog-start-chat.dart';
import 'package:katya/utils/theme_compatibility.dart';


class ModalUserDetails extends StatelessWidget {
  const ModalUserDetails({
    Key? key,
    this.user,
    this.userId,
    this.nested,
  }) : super(key: key);

  final User? user;
  final String? userId;
  final bool? nested; // pop context twice when double nested in a view

  onNavigateToProfile({required BuildContext context, required _Props props}) async {
    Navigator.pushNamed(
      context,
      Routes.userDetails,
      arguments: UserProfileArguments(
        user: props.user,
      ),
    );
  }

  onNavigateToInvite({required BuildContext context, required _Props props}) async {
    Navigator.pushNamed(
      context,
      Routes.searchChats,
      arguments: ChatSearchArguments(
        user: props.user,
      ),
    );
  }

  onMessageUser({required BuildContext context, required _Props props}) async {
    final user = props.user;
    final existingChatId = props.existingChatId;

    // Navigate to existing DM if one already exists
    if (existingChatId.isNotEmpty) {
      return Navigator.popAndPushNamed(
        context,
        Routes.chat,
        arguments: ChatScreenArguments(
          roomId: existingChatId,
          title: user.displayName,
        ),
      );
    }

    // Asking the user to create new DM if there isn't one already
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => DialogStartChat(
        user: user,
        title: Strings.listItemUserDetailsStartChat(user.displayName),
        content: Strings.confirmStartChat,
        onStartChat: () async {
          final String roomIdNew = await props.onCreateChatDirect(user: user) ?? '';
          Navigator.pop(dialogContext);

          if (nested != null && nested!) {
            Navigator.pop(dialogContext);
          }

          if (roomIdNew.isNotEmpty) {
            Navigator.popAndPushNamed(
              context,
              Routes.chat,
              arguments: ChatScreenArguments(
                roomId: existingChatId,
                title: user.displayName,
              ),
            );
          }
        },
        onCancel: () async {
          Navigator.pop(dialogContext);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => StoreConnector<AppState, _Props>(
        distinct: true,
        converter: (Store<AppState> store) => _Props.mapStateToProps(
          store,
          user: user,
          userId: userId,
        ),
        builder: (context, props) => Container(
          constraints: BoxConstraints(
            maxHeight: Dimensions.modalHeightMax,
          ),
          padding: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Avatar(
                            uri: props.user.avatarUri,
                            alt: props.user.displayName ?? props.user.userId,
                            size: Dimensions.avatarSizeDetails,
                            background: props.user.avatarUri == null
                                ? AppColors.hashedColorUser(props.user)
                                : null,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            props.user.displayName ?? '',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          // wrapped with flexible to allow ellipsis
                          child: InkWell(child: Text(
                            props.user.userId ?? '',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                            onLongPress: () async  {
                              await Clipboard.setData(ClipboardData(text: props.user.userId ?? ''));
                              await props.onAddConfirmation('Username copied to clipboard');
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      onTap: () => onMessageUser(
                        context: context,
                        props: props,
                      ),
                      title: Text(
                        Strings.listItemUserDetailsSendMessage,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      leading: Container(
                        padding: EdgeInsets.all(4),
                        margin: EdgeInsets.only(left: 2),
                        child: SvgPicture.asset(
                          Assets.iconMessageCircleBeing,
                          fit: BoxFit.contain,
                          width: Dimensions.iconSize - 2,
                          height: Dimensions.iconSize - 2,
                          semanticsLabel: Strings.semanticsCreatePublicRoom,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () => onNavigateToInvite(
                        context: context,
                        props: props,
                      ),
                      title: Text(
                        Strings.listItemUserDetailsRoomInvite,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      leading: Container(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.mail_outline,
                          size: Dimensions.iconSize,
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () => onNavigateToProfile(
                        context: context,
                        props: props,
                      ),
                      title: Text(
                        Strings.listItemUserDetailsViewProfile,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      leading: Container(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.info_outline,
                          size: Dimensions.iconSize,
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () async {
                        await props.onBlockUser(props.user);
                        Navigator.pop(context);
                      },
                      title: Text(
                        props.blocked
                            ? Strings.listItemUserDetailsUnblockUser
                            : Strings.listItemUserDetailsBlockUser,
                      ),
                      leading: Container(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.block,
                          size: Dimensions.iconSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _Props extends Equatable {
  final User user;
  final bool blocked;
  final bool loading;
  final String existingChatId;
  final Map<String, User> users;
  final Function onBlockUser;
  final Function onAddConfirmation;
  final Function onCreateChatDirect;

  const _Props({
    required this.user,
    required this.users,
    required this.loading,
    required this.blocked,
    required this.existingChatId,
    required this.onCreateChatDirect,
    required this.onBlockUser,
    required this.onAddConfirmation,
  });

  @override
  List<Object> get props => [
        user,
        users,
        existingChatId,
        loading,
        blocked,
      ];

  static _Props mapStateToProps(Store<AppState> store, {User? user, String? userId}) => _Props(
        user: () {
          final users = store.state.userStore.users;
          final loading = store.state.userStore.loading;

          if (user != null && user.userId != null) {
            return user;
          }

          if (userId == null) {
            return User();
          }

          if (!users.containsKey(userId) && !loading) {
            store.dispatch(fetchUser(user: User(userId: userId)));
          }

          return users[userId] ?? User();
        }(),
        users: store.state.userStore.users,
        existingChatId: selectDirectChatIdExisting(
          state: store.state,
          user: user ?? User(userId: userId),
        ),
        loading: store.state.userStore.loading,
        blocked: store.state.userStore.blocked.contains(userId ?? user!.userId),
        onBlockUser: (User user) async {
          await store.dispatch(toggleBlockUser(user: user));
        },
        onCreateChatDirect: ({required User user}) async => store.dispatch(
          createRoom(
            isDirect: true,
            invites: <User>[user],
          ),
        ),
        onAddConfirmation: (String message) async {
          await store.dispatch(addConfirmation(message: message));
        }
      );
}
