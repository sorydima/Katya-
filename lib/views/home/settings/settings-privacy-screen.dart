// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart' as hooks;
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/context/types.dart';
import 'package:katya/global/strings.dart';
import 'package:katya/global/values.dart';
import 'package:katya/store/alerts/actions.dart';
import 'package:katya/store/auth/actions.dart';
import 'package:katya/store/crypto/actions.dart';
import 'package:katya/store/crypto/keys/selectors.dart';
import 'package:katya/store/crypto/sessions/actions.dart';
import 'package:katya/store/crypto/sessions/service/actions.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/settings/actions.dart';
import 'package:katya/store/settings/devices-settings/selectors.dart';
import 'package:katya/store/settings/privacy-settings/actions.dart';
import 'package:katya/store/settings/privacy-settings/selectors.dart';
import 'package:katya/store/settings/privacy-settings/storage.dart';
import 'package:katya/store/settings/selectors.dart';
import 'package:katya/store/settings/storage-settings/actions.dart';
import 'package:katya/store/settings/theme-settings/selectors.dart';
import 'package:katya/utils/theme_compatibility.dart';
import 'package:katya/views/katya.dart';
import 'package:katya/views/widgets/dialogs/dialog-confirm-password.dart';
import 'package:katya/views/widgets/dialogs/dialog-confirm.dart';
import 'package:katya/views/widgets/dialogs/dialog-rounded.dart';
import 'package:katya/views/widgets/dialogs/dialog-text-input.dart';
import 'package:katya/views/widgets/modals/modal-lock-overlay/show-lock-overlay.dart';
import 'package:redux/redux.dart';

class _Props extends Equatable {
  final bool loading;
  final bool valid;
  final bool? typingIndicators;
  final bool screenLockEnabled;

  final String sessionId;
  final String sessionName;
  final String sessionKey;
  final String readReceipts;
  final String keyBackupSchedule;
  final String keyBackupLatest;
  final String keyBackupLocation;

  final Function onToggleTypingIndicators;
  final Function onIncrementReadReceipts;
  final Function onDisabled;
  final Function onResetConfirmAuth;
  final Function onSetScreenLock;
  final Function onRemoveScreenLock;
  final Function onRenameDevice;
  final Function copyToClipboard;

  const _Props({
    required this.valid,
    required this.loading,
    required this.readReceipts,
    required this.keyBackupSchedule,
    required this.keyBackupLatest,
    required this.keyBackupLocation,
    required this.screenLockEnabled,
    required this.typingIndicators,
    required this.sessionId,
    required this.sessionName,
    required this.sessionKey,
    required this.onDisabled,
    required this.onToggleTypingIndicators,
    required this.onIncrementReadReceipts,
    required this.onResetConfirmAuth,
    required this.onSetScreenLock,
    required this.onRemoveScreenLock,
    required this.onRenameDevice,
    required this.copyToClipboard,
  });

  @override
  List<Object?> get props => [
        valid,
        loading,
        typingIndicators,
        keyBackupLatest,
        keyBackupLocation,
        keyBackupSchedule,
        readReceipts,
        sessionId,
        sessionName,
        sessionKey,
        screenLockEnabled,
      ];

  static _Props mapStateToProps(Store<AppState> store, AppContext context) => _Props(
        valid: store.state.authStore.credential != null &&
            store.state.authStore.credential!.value != null &&
            store.state.authStore.credential!.value!.isNotEmpty,
        loading: store.state.authStore.loading,
        screenLockEnabled: selectScreenLockEnabled(context),
        typingIndicators: store.state.settingsStore.typingIndicatorsEnabled,
        keyBackupLatest: store.state.settingsStore.privacySettings.lastBackupMillis,
        keyBackupSchedule: selectKeyBackupSchedule(store.state),
        keyBackupLocation: selectKeyBackupLocation(store.state),
        readReceipts: selectReadReceiptsString(store.state.settingsStore.readReceipts),
        sessionId: store.state.authStore.user.deviceId ?? Values.empty,
        sessionName: selectCurrentDeviceName(store),
        sessionKey: selectCurrentUserSessionKey(store),
        onSetScreenLock: (String matchedPin) async => store.dispatch(setScreenLock(pin: matchedPin)),
        onRemoveScreenLock: (String matchedPin) async => store.dispatch(removeScreenLock(pin: matchedPin)),
        onDisabled: () => store.dispatch(addInProgress()),
        onResetConfirmAuth: () => store.dispatch(resetInteractiveAuth()),
        onToggleTypingIndicators: () => store.dispatch(toggleTypingIndicators()),
        onIncrementReadReceipts: () => store.dispatch(incrementReadReceipts()),
        onRenameDevice: (BuildContext context) async {
          showDialog(
            context: context,
            builder: (dialogContext) => DialogTextInput(
              title: Strings.titleRenameDevice,
              content: Strings.contentRenameDevice,
              randomizeText: true,
              label: selectCurrentDeviceName(store),
              onConfirm: (String newDisplayName) async {
                store.dispatch(
                  renameDevice(
                    deviceId: store.state.authStore.user.deviceId,
                    displayName: newDisplayName,
                  ),
                );
                Navigator.of(dialogContext).pop();
              },
              onCancel: () async {
                Navigator.of(dialogContext).pop();
              },
            ),
          );
        },
        copyToClipboard: (String? clipboardData) async {
          await Clipboard.setData(ClipboardData(text: clipboardData ?? ''));
          store.dispatch(addInfo(message: Strings.alertCopiedToClipboard));
          HapticFeedback.vibrate();
        },
      );
}

class PrivacySettingsScreen extends hooks.HookWidget {
  const PrivacySettingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: const Center(
        child: Text('Privacy Settings - Coming Soon'),
      ),
    );
  }

  Future<void> onConfirmDeactivateAccount(BuildContext context, _Props props) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => DialogConfirm(
        title: Strings.titleDialogConfirmDeactivateAccount,
        content: Strings.warningDeactivateAccount,
        confirmText: Strings.buttonDeactivate.capitalize(),
        confirmStyle: const TextStyle(color: Colors.red),
        onDismiss: () => Navigator.pop(dialogContext),
        onConfirm: () async {
          Navigator.of(dialogContext).pop();
          props.onResetConfirmAuth();
          onConfirmDeactivateAccountFinal(context, props);
        },
      ),
    );
  }

  Future<void> onConfirmDeactivateAccountFinal(BuildContext context, _Props props) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => DialogConfirm(
        title: Strings.titleDialogConfirmDeactivateAccountFinal,
        content: Strings.warrningDeactivateAccountFinal,
        loading: props.loading,
        confirmText: Strings.buttonDeactivate.capitalize(),
        confirmStyle: const TextStyle(color: Colors.red),
        onDismiss: () => Navigator.pop(dialogContext),
        onConfirm: () async {
          Navigator.of(dialogContext).pop();
          await onDeactivateAccount(context, props);
        },
      ),
    );
  }

  Future<void> onDeactivateAccount(BuildContext context, _Props props) async {
    final store = StoreProvider.of<AppState>(context);

    // Attempt to deactivate account
    await store.dispatch(deactivateAccount());

    // Prompt for password if an Interactive Auth sessions was started
    final authSession = store.state.authStore.authSession;
    if (authSession != null) {
      showDialog(
        context: context,
        builder: (dialogContext) => DialogConfirmPassword(
          title: Strings.titleConfirmPassword,
          content: Strings.confirmDeactivate,
          checkLoading: () => store.state.settingsStore.loading,
          checkValid: () =>
              store.state.authStore.credential != null &&
              store.state.authStore.credential!.value != null &&
              store.state.authStore.credential!.value!.isNotEmpty,
          onConfirm: () async {
            await store.dispatch(deactivateAccount());
            Navigator.of(dialogContext).pop();
          },
          onCancel: () async {
            Navigator.of(dialogContext).pop();
          },
        ),
      );
    }
  }

  Future<void> onImportSessionKeys(BuildContext context) async {
    final store = StoreProvider.of<AppState>(context);

    final file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (file == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => DialogTextInput(
        title: Strings.titleImportSessionKeys,
        content: Strings.contentImportSessionKeys,
        label: Strings.labelPassword,
        initialValue: '',
        confirmText: Strings.buttonTextImport,
        obscureText: true,
        loading: store.state.settingsStore.loading,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        onCancel: () async {
          Navigator.of(dialogContext).pop();
        },
        onConfirm: (String password) async {
          await store.dispatch(importSessionKeys(file, password: password));

          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  Future<void> onUpdateBackupLocation({
    required BuildContext context,
  }) async {
    final store = StoreProvider.of<AppState>(context);

    final selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Backup Directory',
      initialDirectory: store.state.settingsStore.storageSettings.keyBackupLocation,
    );

    if (selectedDirectory == null) {
      store.dispatch(addInfo(message: 'No directory was selected'));
    } else {
      store.dispatch(SetKeyBackupLocation(
        location: selectedDirectory,
      ));
    }
  }

  Future onUpdateBackupSchedulePassword({
    required BuildContext context,
    required Function onComplete,
  }) async {
    final store = StoreProvider.of<AppState>(context);

    final password = await loadBackupPassword();

    if (password.isNotEmpty) {
      return onComplete();
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => DialogTextInput(
        title: 'Scheduled Backup Password',
        content: Strings.contentExportSessionKeysEnterPassword,
        obscureText: true,
        loading: store.state.settingsStore.loading,
        label: Strings.labelPassword,
        initialValue: '',
        confirmText: Strings.buttonSave,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        onCancel: () async {
          Navigator.of(dialogContext).pop();
        },
        onConfirm: (String password) async {
          await store.dispatch(SetKeyBackupPassword(
            password: password,
          ));

          Navigator.of(dialogContext).pop();
          onComplete();
        },
      ),
    );
  }

  Future<void> onUpdateBackupScheduleNotice({
    required BuildContext context,
    bool isDefault = false,
  }) async {
    final store = StoreProvider.of<AppState>(context);
    if (isDefault && Platform.isIOS) {
      await showDialog(
        context: context,
        builder: (dialogContext) => DialogConfirm(
          title: Strings.titleDialogKeyBackupWarning,
          content: Strings.contentKeyBackupWarning,
          confirmText: Strings.buttonConfirm,
          confirmStyle: TextStyle(color: Theme.of(context).primaryColor),
          dismissText: Strings.buttonCancel,
          onDismiss: () {
            store.dispatch(SetKeyBackupInterval(
              duration: Duration.zero,
            ));
            Navigator.pop(dialogContext);
          },
          onConfirm: () {
            Navigator.pop(dialogContext);
          },
        ),
      );
    }
  }

  Future<void> onUpdateBackupSchedule({
    required BuildContext context,
  }) async {
    final store = StoreProvider.of<AppState>(context);
    const defaultPadding = EdgeInsets.symmetric(horizontal: 10);
    final isDefault = store.state.settingsStore.privacySettings.keyBackupInterval == Duration.zero;

    final onSelect = (BuildContext dialogContext, Duration duration) {
      store.dispatch(
        SetKeyBackupInterval(duration: duration),
      );
      Navigator.pop(dialogContext);
      onUpdateBackupScheduleNotice(
        context: context,
        isDefault: isDefault,
      );

      if (isDefault) {
        store.dispatch(startKeyBackupService());
      }
    };

    onUpdateBackupSchedulePassword(
      context: context,
      onComplete: () async => showDialog(
        context: context,
        builder: (dialogContext) => DialogRounded(
          title: 'Set Key Backup Schedule',
          children: [
            ListTile(
              title: Padding(
                  padding: defaultPadding,
                  child: Text(
                    'Manual Only',
                    style: Theme.of(context).textTheme.subtitle1,
                  )),
              onTap: () {
                onSelect(dialogContext, Duration.zero);
              },
            ),
            ListTile(
              title: Padding(
                  padding: defaultPadding,
                  child: Text(
                    'Every 15 Minutes',
                    style: Theme.of(context).textTheme.subtitle1,
                  )),
              onTap: () {
                onSelect(dialogContext, const Duration(minutes: 15));
              },
            ),
            ListTile(
              title: Padding(
                  padding: defaultPadding,
                  child: Text(
                    'Every hour',
                    style: Theme.of(context).textTheme.subtitle1,
                  )),
              onTap: () {
                onSelect(dialogContext, const Duration(hours: 1));
              },
            ),
            ListTile(
              title: Padding(
                  padding: defaultPadding,
                  child: Text(
                    'Every 6 hours',
                    style: Theme.of(context).textTheme.subtitle1,
                  )),
              onTap: () {
                onSelect(dialogContext, const Duration(hours: 6));
              },
            ),
            ListTile(
              title: Padding(
                padding: defaultPadding,
                child: Text(
                  'Every 12 hours',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              onTap: () {
                onSelect(dialogContext, const Duration(hours: 12));
              },
            ),
            ListTile(
              title: Padding(
                padding: defaultPadding,
                child: Text(
                  'Every day',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              onTap: () {
                onSelect(dialogContext, const Duration(hours: 24));
              },
            ),
            ListTile(
              title: Padding(
                padding: defaultPadding,
                child: Text(
                  'Every week',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              onTap: () {
                onSelect(dialogContext, const Duration(days: 7));
              },
            ),
            ListTile(
              title: Padding(
                padding: defaultPadding,
                child: Text(
                  'Once a month',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              onTap: () {
                onSelect(dialogContext, const Duration(days: 29));
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> onExportSessionKeys({
    required _Props props,
    required BuildContext context,
  }) async {
    final store = StoreProvider.of<AppState>(context);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => DialogTextInput(
        title: Strings.titleDialogBackupSessionKeys,
        content: Strings.contentExportSessionKeys,
        obscureText: true,
        loading: store.state.settingsStore.loading,
        label: Strings.labelPassword,
        initialValue: '',
        confirmText: Strings.buttonSave,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        onCancel: () async {
          Navigator.of(dialogContext).pop();
        },
        onConfirm: (String password) async {
          await store.dispatch(exportSessionKeys(password));
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  Future<void> onDeleteSessionKeys({
    required _Props props,
    required BuildContext context,
  }) async {
    final store = StoreProvider.of<AppState>(context);
    await showDialog(
      context: context,
      builder: (dialogContext) => DialogConfirm(
        title: Strings.titleConfirmDeleteKeys,
        content: Strings.confirmDeleteKeys,
        loading: props.loading,
        confirmText: Strings.buttonTextConfirmDeleteKeys,
        confirmStyle: const TextStyle(color: Colors.red),
        onDismiss: () => Navigator.pop(dialogContext),
        onConfirm: () async {
          await store.dispatch(resetSessionKeys());
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  Future<void> onSetScreenLockPin({
    required _Props props,
    required BuildContext context,
  }) async {
    if (props.screenLockEnabled) {
      await showDialog(
        context: context,
        builder: (dialogContext) => DialogConfirm(
          title: Strings.titleDialogRemoveScreenLock,
          content: Strings.contentRemoveScreenLock,
          loading: props.loading,
          confirmText: Strings.buttonTextRemove,
          confirmStyle: const TextStyle(color: Colors.red),
          onDismiss: () => Navigator.pop(dialogContext),
          onConfirm: () async {
            Navigator.of(dialogContext).pop();

            showLockOverlay(
              context: context,
              canCancel: true,
              maxRetries: 0,
              onMaxRetries: (stuff) {
                Navigator.of(context).pop();
              },
              onLeftButtonTap: () {
                Navigator.of(context).pop();
                return Future.value();
              },
              title: Text(Strings.titleDialogEnterScreenLockPin),
              onVerify: (String answer) async {
                return Future.value(true);
              },
              onConfirmed: (String matchedText) async {
                await props.onRemoveScreenLock(matchedText);
                katya.reloadCurrentContext(context);
              },
            );
          },
        ),
      );
    } else {
      showLockOverlay(
        context: context,
        canCancel: true,
        confirmMode: true,
        onLeftButtonTap: () {
          Navigator.of(context).pop();
          return Future.value();
        },
        title: Text(Strings.titleDialogEnterScreenLockPin),
        onVerify: (String answer) async {
          return Future.value(true);
        },
        onConfirmed: (String matchedText) async {
          await props.onSetScreenLock(matchedText);
          katya.reloadCurrentContext(context);
        },
      );
    }
  }
}
