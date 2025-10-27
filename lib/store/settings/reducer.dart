import 'package:katya/global/https.dart';
import 'package:katya/store/settings/chat-settings/actions.dart';
import 'package:katya/store/settings/chat-settings/model.dart';
import 'package:katya/store/settings/notification-settings/actions.dart';
import 'package:katya/store/settings/privacy-settings/actions.dart';
import 'package:katya/store/settings/proxy-settings/actions.dart';
import 'package:katya/store/settings/storage-settings/actions.dart';
import 'package:katya/store/settings/theme-settings/actions.dart';
import './actions.dart';
import './state.dart';

SettingsStore settingsReducer([
  SettingsStore state = const SettingsStore(),
  dynamic action,
]) {
  switch (action.runtimeType) {
    case SetLoadingSettings:
      return state.copyWith(
        loading: action.loading,
      );
    case SetPrimaryColor:
      return state.copyWith(
        themeSettings: state.themeSettings.copyWith(primaryColor: action.color),
      );
    case SetAccentColor:
      return state.copyWith(
        themeSettings: state.themeSettings.copyWith(accentColor: action.color),
      );
    case SetAppBarColor:
      return state.copyWith(
        themeSettings: state.themeSettings.copyWith(appBarColor: action.color),
      );
    case SetFontName:
      return state.copyWith(
        themeSettings: state.themeSettings.copyWith(fontName: action.fontName),
      );
    case SetFontSize:
      return state.copyWith(
        themeSettings: state.themeSettings.copyWith(fontSize: action.fontSize),
      );
    case SetMessageSize:
      return state.copyWith(
        themeSettings: state.themeSettings.copyWith(messageSize: action.messageSize),
      );
    case SetAvatarShape:
      return state.copyWith(
        themeSettings: state.themeSettings.copyWith(avatarShape: action.avatarShape),
      );
    case SetMainFabType:
      final action0 = action as SetMainFabType;
      return state.copyWith(
        themeSettings: state.themeSettings.copyWith(mainFabType: action0.fabType),
      );
    case SetMainFabLocation:
      final action0 = action as SetMainFabLocation;
      return state.copyWith(
        themeSettings: state.themeSettings.copyWith(mainFabLocation: action0.fabLocation),
      );
    case SetMainFabLabels:
      final action0 = action as SetMainFabLabels;
      return state.copyWith(
        themeSettings: state.themeSettings.copyWith(mainFabLabel: action0.fabLabels),
      );
    case SetDevices:
      return state.copyWith(
        devices: action.devices,
      );
    case SetPusherToken:
      return state.copyWith(
        pusherToken: action.token,
      );
    case LogAppAgreement:
      return state.copyWith(
        alphaAgreement: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    case SetRoomPrimaryColor:
      final chatSettings = Map<String, ChatSetting>.from(state.chatSettings);

      // Initialize chat settings if null
      if (chatSettings[action.roomId] == null) {
        chatSettings[action.roomId] = ChatSetting(
          roomId: action.roomId,
          language: state.language,
        );
      }

      chatSettings[action.roomId] = chatSettings[action.roomId]!.copyWith(
        primaryColor: action.color,
      );
      return state.copyWith(
        chatSettings: chatSettings,
      );
    case SetLanguage:
      return state.copyWith(
        language: action.language,
      );
    case SetThemeType:
      return state.copyWith(
        themeSettings: state.themeSettings.copyWith(themeType: action.themeType),
      );
    case ToggleEnterSend:
      return state.copyWith(
        enterSendEnabled: !state.enterSendEnabled,
      );
    case ToggleAutocorrect:
      return state.copyWith(
        autocorrectEnabled: !state.autocorrectEnabled,
      );
    case ToggleSuggestions:
      return state.copyWith(
        suggestionsEnabled: !state.suggestionsEnabled,
      );
    case SetSyncInterval:
      return state.copyWith(
        syncInterval: action.syncInterval,
      );
    case SetPollTimeout:
      return state.copyWith(
        syncPollTimeout: action.syncPollTimeout,
      );
    case ToggleTypingIndicators:
      return state.copyWith(
        typingIndicatorsEnabled: !state.typingIndicatorsEnabled,
      );
    case ToggleTimeFormat:
      return state.copyWith(
        timeFormat24Enabled: !state.timeFormat24Enabled,
      );
    case ToggleDismissKeyboard:
      return state.copyWith(
        dismissKeyboardEnabled: !state.dismissKeyboardEnabled,
      );
    case ToggleAutoDownload:
      return state.copyWith(
        autoDownloadEnabled: !state.autoDownloadEnabled,
      );
    case ToggleAutoDownloadImages:
      return state.copyWith(
        autoDownloadImages: !state.autoDownloadImages,
      );
    case ToggleAutoDownloadAudio:
      return state.copyWith(
        autoDownloadAudio: !state.autoDownloadAudio,
      );
    case ToggleAutoDownloadVideo:
      return state.copyWith(
        autoDownloadVideo: !state.autoDownloadVideo,
      );
    case ToggleAutoDownloadFiles:
      return state.copyWith(
        autoDownloadFiles: !state.autoDownloadFiles,
      );
    case SetLastBackupMillis:
      final action0 = action as SetLastBackupMillis;
      return state.copyWith(
        privacySettings: state.privacySettings.copyWith(
          lastBackupMillis: action0.timestamp,
        ),
      );
    case SetKeyBackupPassword:
      // NOTE: saved to cold storage only instead of state
      return state;
    case SetKeyBackupLocation:
      final action0 = action as SetKeyBackupLocation;
      return state.copyWith(
        storageSettings: state.storageSettings.copyWith(
          keyBackupLocation: action0.location,
        ),
      );
    case SetKeyBackupInterval:
      final action0 = action as SetKeyBackupInterval;
      return state.copyWith(
        privacySettings: state.privacySettings.copyWith(
          keyBackupInterval: action0.duration,
          lastBackupMillis: DateTime.now().millisecondsSinceEpoch.toString(),
        ),
      );
    case ToggleProxy:
      final state0 = state.copyWith(
        proxySettings: state.proxySettings.copyWith(
          enabled: !state.proxySettings.enabled,
        ),
      );

      httpClient = createClient(proxySettings: state0.proxySettings);

      return state0;
    case SetProxyHost:
      final state0 = state.copyWith(
        proxySettings: state.proxySettings.copyWith(host: action.host),
      );

      httpClient = createClient(proxySettings: state0.proxySettings);

      return state0;
    case SetProxyPort:
      final state0 = state.copyWith(
        proxySettings: state.proxySettings.copyWith(port: action.port),
      );

      httpClient = createClient(proxySettings: state0.proxySettings);

      return state0;
    case ToggleProxyAuthentication:
      final state0 = state.copyWith(
        proxySettings: state.proxySettings.copyWith(authenticationEnabled: !state.proxySettings.authenticationEnabled),
      );

      httpClient = createClient(proxySettings: state0.proxySettings);

      return state0;
    case SetProxyUsername:
      final state0 = state.copyWith(
        proxySettings: state.proxySettings.copyWith(username: action.username),
      );

      httpClient = createClient(proxySettings: state0.proxySettings);

      return state0;
    case SetProxyPassword:
      final state0 = state.copyWith(
        proxySettings: state.proxySettings.copyWith(password: action.password),
      );

      httpClient = createClient(proxySettings: state0.proxySettings);

      return state0;
    case SetReadReceipts:
      final action0 = action as SetReadReceipts;
      return state.copyWith(
        readReceipts: action0.readReceipts,
      );
    case ToggleMembershipEvents:
      return state.copyWith(
        membershipEventsEnabled: !state.membershipEventsEnabled,
      );
    case ToggleRoomTypeBadges:
      return state.copyWith(
        roomTypeBadgesEnabled: !state.roomTypeBadgesEnabled,
      );
    case ToggleNotifications:
      return state.copyWith(
        notificationSettings: state.notificationSettings.copyWith(enabled: !state.notificationSettings.enabled),
      );
    case SetNotificationSettings:
      return state.copyWith(notificationSettings: action.settings);
    default:
      return state;
  }
}
