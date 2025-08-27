import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:katya/global/strings.dart';
import 'package:katya/global/values.dart';
import 'package:katya/global/weburl.dart';
import 'package:katya/store/hooks.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/rooms/actions.dart';
import 'package:katya/store/rooms/room/model.dart';
import 'package:katya/store/settings/theme-settings/model.dart';
import 'package:katya/store/settings/theme-settings/selectors.dart';
import 'package:katya/store/sync/selectors.dart';
import 'package:katya/store/user/model.dart';
import 'package:katya/views/home/chat/chat-screen.dart';
import 'package:katya/views/navigation.dart';
import 'package:katya/views/widgets/appbars/appbar-avatar.dart';
import 'package:katya/views/widgets/containers/menu-rounded.dart';
import 'package:katya/views/widgets/dialogs/dialog-options.dart';
import 'package:katya/utils/theme_compatibility.dart';

enum Options {
  newGroup,
  markAllRead,
  inviteFriends,
  settings,
  licenses,
  help,
}

class AppBarHome extends HookWidget implements PreferredSizeWidget {
  const AppBarHome({
    Key? key,
    this.onToggleSearch,
  }) : super(key: key);

  final Function? onToggleSearch;

  @override
  Size get preferredSize => AppBar().preferredSize;

  @override
  Widget build(BuildContext context) {
    final dispatch = useDispatch<AppState>();

    final assetColor = useMemoized(
      () => computeContrastColorText(
        Theme.of(context).appBarTheme.backgroundColor,
      ),
      [],
    );

    final offline = useSelector<AppState, bool>(
      (state) => state.syncStore.offline,
    );
    final syncing = useSelector<AppState, bool>(
      (state) => selectSyncingStatus(state),
    );
    final unauthed = useSelector<AppState, bool>(
      (state) => state.syncStore.unauthed,
    );

    final themeType = useSelector<AppState, ThemeType>(
      (state) => state.settingsStore.themeSettings.themeType,
    );
    final currentUser = useSelector<AppState, User>(
      (state) => state.authStore.user,
    );

    onMarkAllRead() {
      dispatch(markRoomsReadAll());
    }

    onSelectHelp() async {
      showDialog(
        context: context,
        builder: (dialogContext) => DialogOptions(
          title: 'How can we help?',
          content: Strings.contentSupportDialog,
          confirmStyle: TextStyle(color: Colors.grey),
          dismissStyle: TextStyle(color: Colors.blue),
          dismissText: 'Join Support chat',
          confirmText: 'Email our team',
          onDismiss: () async {
            final supportRoom = Room(
              id: Values.supportChatId,
              alias: Values.supportChatAlias,
            );

            await dispatch(joinRoom(room: supportRoom));

            Navigator.of(dialogContext).pop();

            Navigator.pushNamed(
              context,
              Routes.chat,
              arguments: ChatScreenArguments(
                roomId: supportRoom.id,
                title: 'Katya ® 👽 AI 🧠 Platform Support!',
              ),
            );
          },
          onConfirm: () async {
            Navigator.of(dialogContext).pop();
            await launchUrl(Values.openHelpUrl);
          },
        ),
      );
    }

    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 16.00,
      title: Row(
        children: <Widget>[
          AppBarAvatar(
            user: currentUser,
            offline: offline,
            syncing: syncing ?? false,
            unauthed: unauthed ?? false,
            themeType: themeType ?? ThemeType.Light,
            tooltip: Strings.tooltipProfileAndSettings,
            onPressed: () {
              Navigator.pushNamed(context, Routes.settingsProfile);
            },
          ),
          Text(
            Values.appName,
            style: Theme.of(context).textTheme.headline6!.copyWith(
                  fontWeight: FontWeight.w400,
                  color: assetColor,
                ),
          ),
        ],
      ),
      actions: <Widget>[
        IconButton(
          color: assetColor,
          icon: Icon(Icons.search),
          tooltip: Strings.tooltipSearchChats,
          onPressed: () => onToggleSearch?.call(),
        ),
        RoundedPopupMenu<Options>(
          icon: Icon(
            Icons.more_vert,
            color: assetColor,
          ),
          onSelected: (Options result) {
            switch (result) {
              case Options.newGroup:
                Navigator.pushNamed(context, Routes.groupCreate);
                break;
              case Options.markAllRead:
                onMarkAllRead();
                break;
              case Options.settings:
                Navigator.pushNamed(context, Routes.settings);
                break;
              case Options.help:
                onSelectHelp();
                break;
              default:
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Options>>[
            PopupMenuItem<Options>(
              value: Options.newGroup,
              child: Text(Strings.buttonTextCreateGroup),
            ),
            PopupMenuItem<Options>(
              value: Options.markAllRead,
              child: Text(Strings.buttonTextMarkAllRead),
            ),
            PopupMenuItem<Options>(
              value: Options.inviteFriends,
              enabled: false,
              child: Text(Strings.buttonTextInvite),
            ),
            PopupMenuItem<Options>(
              value: Options.settings,
              child: Text(Strings.buttonTextSettings),
            ),
            PopupMenuItem<Options>(
              value: Options.help,
              child: Text(Strings.buttonTextSupport),
            ),
          ],
        )
      ],
    );
  }
}
