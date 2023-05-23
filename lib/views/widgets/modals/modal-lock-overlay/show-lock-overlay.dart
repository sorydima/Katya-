import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/configurations/input_button_config.dart';
import 'package:flutter_screen_lock/configurations/screen_lock_config.dart';
import 'package:flutter_screen_lock/heading_title.dart';
import 'package:flutter_screen_lock/screen_lock.dart';
import 'package:katya/views/widgets/modals/modal-lock-overlay/input-secrets-config.dart';
import 'package:katya/views/widgets/modals/modal-lock-overlay/lock-controller.dart';
import 'package:katya/views/widgets/modals/modal-lock-overlay/lock-overlay.dart';

Future<void>? showLockOverlay({
  required BuildContext context,
  required Future<bool> Function(String) onVerify,
  ScreenLockConfig screenLockConfig = const ScreenLockConfig(),
  InputSecretsConfig secretsConfig = const InputSecretsConfig(),
  InputButtonConfig inputButtonConfig = const InputButtonConfig(),
  bool canCancel = true,
  bool confirmMode = false,
  int digits = 9,
  int maxRetries = 0,
  LockController? lockController,
  void Function(String pin)? onUnlocked,
  void Function(int retries)? onError,
  void Function(int retries)? onMaxRetries,
  void Function()? onOpened,
  void Function(String matchedText)? onConfirmed,
  Future<void> Function()? onLeftButtonTap,
  Widget? rightButtonChild,
  Widget? footer,
  Widget? cancelButton,
  Widget? deleteButton,
  Widget title = const HeadingTitle(text: 'Please enter your passcode.'),
  Widget confirmTitle = const HeadingTitle(text: 'Please enter confirm passcode.'),
}) {
  Navigator.push(
    context,
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.8),
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secodaryAnimation,
      ) {
        animation.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            if (onOpened != null) {
              onOpened();
            }
          }
        });
        return LockOverlay(
          screenLockConfig: screenLockConfig,
          inputSecretsConfig: secretsConfig,
          inputButtonConfig: inputButtonConfig,
          canCancel: canCancel,
          confirmMode: confirmMode,
          maxLength: digits,
          maxRetries: maxRetries,
          onUnlocked: onUnlocked,
          onError: onError,
          onMaxRetires: onMaxRetries,
          onConfirmed: onConfirmed,
          onVerify: onVerify,
          onLeftButtonTap: onLeftButtonTap,
          rightButtonChild: rightButtonChild,
          footer: footer,
          deleteButton: deleteButton,
          cancelButton: cancelButton,
          title: title,
          confirmTitle: confirmTitle,
          lockController: lockController,
        );
      },
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 2.4),
            end: Offset.zero,
          ).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(0.0, 2.4),
            ).animate(secondaryAnimation),
            child: child,
          ),
        );
      },
    ),
  );
  return null;
}
