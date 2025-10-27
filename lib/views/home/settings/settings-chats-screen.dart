import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/global/colors.dart';
import 'package:katya/global/dimensions.dart';
import 'package:katya/global/strings.dart';
import 'package:katya/global/values.dart';
import 'package:katya/store/alerts/actions.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/settings/actions.dart';
import 'package:katya/utils/theme_compatibility.dart';
import 'package:katya/views/navigation.dart';
import 'package:katya/views/widgets/appbars/appbar-normal.dart';
import 'package:katya/views/widgets/containers/card-section.dart';
import 'package:redux/redux.dart';

class SettingsChatsScreen extends StatelessWidget {
  const SettingsChatsScreen({super.key});

  String displayThemeType(String themeTypeName) {
    return themeTypeName.split('.')[1].toLowerCase();
  }

  @override
  Widget build(BuildContext context) => StoreConnector<AppState, Props>(
        distinct: true,
        converter: (Store<AppState> store) => Props.mapStateToProps(store),
        builder: (context, props) {
          final double width = MediaQuery.of(context).size.width;

          return Scaffold(
            appBar: AppBarNormal(
              title: Strings.titleChatSettings,
            ),
            body: SingleChildScrollView(
              child: Container(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: <Widget>[
                      CardSection(
                        child: Column(
                          children: [
                            Container(
                              width: width,
                              padding: Dimensions.listPadding,
                              child: Text(
                                Strings.headerGeneral,
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => props.onDisabled(),
                              child: ListTile(
                                onTap: () => Navigator.pushNamed(context, Routes.settingsLanguages),
                                contentPadding: Dimensions.listPadding,
                                title: Text(
                                  Strings.listItemSettingsLanguage,
                                ),
                                trailing: Text(props.language!),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => props.onDisabled(),
                              child: ListTile(
                                enabled: false,
                                contentPadding: Dimensions.listPadding,
                                title: Text(
                                  Strings.listItemSettingsShowMembershipEvents,
                                ),
                                subtitle: Text(
                                  Strings.subtitleShowMembershipEvents,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                trailing: Switch(
                                  value: false,
                                  inactiveThumbColor: const Color(AppColors.greyDisabled),
                                  onChanged: (showMembershipEvents) {},
                                ),
                              ),
                            ),
                            ListTile(
                              onTap: () => props.onToggleEnterSend(),
                              contentPadding: Dimensions.listPadding,
                              title: Text(
                                Strings.listItemSettingsEnterSends,
                              ),
                              subtitle: Text(
                                Strings.subtitleEnterSends,
                                style: Theme.of(context).textTheme.caption,
                              ),
                              trailing: Switch(
                                value: props.enterSend,
                                onChanged: (enterSend) => props.onToggleEnterSend(),
                              ),
                            ),
                            ListTile(
                              onTap: () => props.onToggleAutocorrect(),
                              contentPadding: Dimensions.listPadding,
                              title: Text(Strings.titleToggleAutocorrect),
                              subtitle: Text(
                                Strings.subtitleToggleAutocorrect,
                                style: Theme.of(context).textTheme.caption,
                              ),
                              trailing: Switch(
                                value: props.autocorrect,
                                onChanged: (autocorrect) => props.onToggleAutocorrect(),
                              ),
                            ),
                            ListTile(
                              onTap: () => props.onToggleSuggestions(),
                              contentPadding: Dimensions.listPadding,
                              title: Text(Strings.titleToggleSuggestions),
                              subtitle: Text(
                                Strings.subtitleToggleSuggestions,
                                style: Theme.of(context).textTheme.caption,
                              ),
                              trailing: Switch(
                                value: props.suggestions,
                                onChanged: (suggestions) => props.onToggleSuggestions(),
                              ),
                            ),
                            ListTile(
                              onTap: () => props.onToggleTimeFormat(),
                              contentPadding: Dimensions.listPadding,
                              title: Text(
                                Strings.listItemSettings24hFormat,
                              ),
                              subtitle: Text(
                                Strings.subtitle24hFormat,
                                style: Theme.of(context).textTheme.caption,
                              ),
                              trailing: Switch(
                                value: props.timeFormat24,
                                onChanged: (value) => props.onToggleTimeFormat(),
                              ),
                            ),
                            ListTile(
                              onTap: () => props.onToggleDismissKeyboard(),
                              contentPadding: Dimensions.listPadding,
                              title: Text(
                                Strings.listItemSettingsDismissKeyboard,
                              ),
                              subtitle: Text(
                                Strings.subtitleDismissKeyboard,
                                style: Theme.of(context).textTheme.caption,
                              ),
                              trailing: Switch(
                                value: props.dismissKeyboard,
                                onChanged: (value) => props.onToggleDismissKeyboard(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CardSection(
                        child: Column(
                          children: [
                            Container(
                              width: width,
                              padding: Dimensions.listPadding,
                              child: Text(
                                Strings.headerOrdering,
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => props.onDisabled(),
                              child: ListTile(
                                contentPadding: Dimensions.listPadding,
                                title: Text(
                                  Strings.listItemSettingsSortBy,
                                ),
                                trailing: Text(
                                  Strings.labelTimestamp, //TODO
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => props.onDisabled(),
                              child: ListTile(
                                contentPadding: Dimensions.listPadding,
                                title: Text(
                                  Strings.listItemSettingsGroupBy,
                                ),
                                trailing: Text(
                                  Strings.labelNone, //TODO
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CardSection(
                        child: Column(
                          children: [
                            Container(
                              width: width,
                              padding: Dimensions.listPadding,
                              child: Text(
                                Strings.headerMedia,
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => props.onDisabled(),
                              child: ListTile(
                                enabled: false,
                                contentPadding: Dimensions.listPadding,
                                title: Text(
                                  Strings.listItemSettingsViewUploadedMedia,
                                ),
                                subtitle: Text(
                                  Strings.subtitleViewUploadedMedia,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CardSection(
                        child: Column(
                          children: [
                            Container(
                              width: width,
                              padding: Dimensions.listPadding,
                              child: Text(
                                Strings.headerMediaAutoDownload,
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),
                            ListTile(
                              onTap: () => props.onToggleAutoDownload(),
                              contentPadding: Dimensions.listPadding,
                              title: Text(
                                Strings.listItemSettingsAutoDownload,
                              ),
                              subtitle: Text(
                                props.autoDownload ? Strings.labelOn : Strings.labelOff,
                                style: Theme.of(context).textTheme.caption,
                              ),
                              trailing: Switch(
                                value: props.autoDownload,
                                onChanged: (enabled) => props.onToggleAutoDownload(),
                              ),
                            ),
                            ListTile(
                              onTap: () => props.onToggleAutoImages(),
                              contentPadding: Dimensions.listPadding,
                              title: const Text('Auto-download images'),
                              trailing: Switch(
                                value: props.autoImages,
                                onChanged: (enabled) => props.onToggleAutoImages(),
                              ),
                            ),
                            ListTile(
                              onTap: () => props.onToggleAutoAudio(),
                              contentPadding: Dimensions.listPadding,
                              title: const Text('Auto-download audio'),
                              trailing: Switch(
                                value: props.autoAudio,
                                onChanged: (enabled) => props.onToggleAutoAudio(),
                              ),
                            ),
                            ListTile(
                              onTap: () => props.onToggleAutoVideo(),
                              contentPadding: Dimensions.listPadding,
                              title: const Text('Auto-download video'),
                              trailing: Switch(
                                value: props.autoVideo,
                                onChanged: (enabled) => props.onToggleAutoVideo(),
                              ),
                            ),
                            ListTile(
                              onTap: () => props.onToggleAutoFiles(),
                              contentPadding: Dimensions.listPadding,
                              title: const Text('Auto-download files'),
                              trailing: Switch(
                                value: props.autoFiles,
                                onChanged: (enabled) => props.onToggleAutoFiles(),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => props.onDisabled(),
                              child: ListTile(
                                enabled: false,
                                contentPadding: Dimensions.listPadding,
                                title: Text(
                                  Strings.listItemSettingsWhenUsingMobileData,
                                ),
                                subtitle: Text(
                                  Strings.subtitleImagesAudioVideoFiles, //TODO
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => props.onDisabled(),
                              child: ListTile(
                                enabled: false,
                                contentPadding: Dimensions.listPadding,
                                title: Text(
                                  Strings.listItemSettingsWhenUsingWiFi,
                                ),
                                subtitle: Text(
                                  Strings.subtitleImagesAudioVideoFiles, //TODO
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => props.onDisabled(),
                              child: ListTile(
                                enabled: false,
                                contentPadding: Dimensions.listPadding,
                                title: Text(
                                  Strings.listItemSettingsWhenRoaming,
                                ),
                                subtitle: Text(
                                  Strings.subtitleImagesAudioVideoFiles, //TODO
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
          );
        },
      );
}

class Props extends Equatable {
  final String? language;

  final bool enterSend;
  final bool autocorrect;
  final bool suggestions;
  final bool timeFormat24;
  final bool dismissKeyboard;
  final bool autoDownload;
  final bool autoImages;
  final bool autoAudio;
  final bool autoVideo;
  final bool autoFiles;

  final Function onDisabled;
  final Function onIncrementLanguage;
  final Function onToggleEnterSend;
  final Function onToggleAutocorrect;
  final Function onToggleSuggestions;
  final Function onToggleTimeFormat;
  final Function onToggleAutoDownload;
  final Function onToggleAutoImages;
  final Function onToggleAutoAudio;
  final Function onToggleAutoVideo;
  final Function onToggleAutoFiles;
  final Function onToggleDismissKeyboard;

  const Props({
    required this.language,
    required this.enterSend,
    required this.autocorrect,
    required this.suggestions,
    required this.timeFormat24,
    required this.dismissKeyboard,
    required this.autoDownload,
    required this.autoImages,
    required this.autoAudio,
    required this.autoVideo,
    required this.autoFiles,
    required this.onDisabled,
    required this.onIncrementLanguage,
    required this.onToggleEnterSend,
    required this.onToggleAutocorrect,
    required this.onToggleSuggestions,
    required this.onToggleTimeFormat,
    required this.onToggleDismissKeyboard,
    required this.onToggleAutoDownload,
    required this.onToggleAutoImages,
    required this.onToggleAutoAudio,
    required this.onToggleAutoVideo,
    required this.onToggleAutoFiles,
  });

  @override
  List<Object?> get props => [
        language,
        enterSend,
        autocorrect,
        suggestions,
        autoDownload,
        autoImages,
        autoAudio,
        autoVideo,
        autoFiles,
        timeFormat24,
        dismissKeyboard,
      ];

  static Props mapStateToProps(Store<AppState> store) => Props(
        language: toDisplayName(store.state.settingsStore.language),
        enterSend: store.state.settingsStore.enterSendEnabled,
        autocorrect: store.state.settingsStore.autocorrectEnabled,
        suggestions: store.state.settingsStore.suggestionsEnabled,
        timeFormat24: store.state.settingsStore.timeFormat24Enabled,
        dismissKeyboard: store.state.settingsStore.dismissKeyboardEnabled,
        autoDownload: store.state.settingsStore.autoDownloadEnabled,
        autoImages: store.state.settingsStore.autoDownloadImages,
        autoAudio: store.state.settingsStore.autoDownloadAudio,
        autoVideo: store.state.settingsStore.autoDownloadVideo,
        autoFiles: store.state.settingsStore.autoDownloadFiles,
        onIncrementLanguage: () {
          store.dispatch(addInfo(
            message: Strings.alertAppRestartEffect,
            action: Strings.buttonDismiss,
          ));
          store.dispatch(incrementLanguage());
        },
        onDisabled: () => store.dispatch(addInProgress()),
        onToggleEnterSend: () => store.dispatch(toggleEnterSend()),
        onToggleAutocorrect: () => store.dispatch(toggleAutocorrect()),
        onToggleSuggestions: () => store.dispatch(toggleSuggestions()),
        onToggleTimeFormat: () => store.dispatch(toggleTimeFormat()),
        onToggleAutoDownload: () => store.dispatch(toggleAutoDownload()),
        onToggleAutoImages: () => store.dispatch(ToggleAutoDownloadImages()),
        onToggleAutoAudio: () => store.dispatch(ToggleAutoDownloadAudio()),
        onToggleAutoVideo: () => store.dispatch(ToggleAutoDownloadVideo()),
        onToggleAutoFiles: () => store.dispatch(ToggleAutoDownloadFiles()),
        onToggleDismissKeyboard: () => store.dispatch(toggleDismissKeyboard()),
      );
}
