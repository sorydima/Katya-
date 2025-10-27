import 'package:flutter/material.dart';
import 'package:katya/views/widgets/modals/modal-lock-overlay/lock-controller.dart';
import 'package:katya/views/widgets/modals/modal-lock-overlay/lock-overlay.dart';

class ShowLockOverlayArguments {
  final Object screenLockConfig;
  final Object inputButtonConfig;
  final Object inputSecretsConfig;
  final bool canCancel;
  final bool confirmMode;
  final int digits;
  final int maxRetries;
  final LockController? lockController;
  final void Function(String pin)? onUnlocked;
  final void Function(int retries)? onError;
  final void Function(int retries)? onMaxRetries;
  final void Function()? onOpened;
  final void Function(String matchedText)? onConfirmed;
  final Future<void> Function()? onLeftButtonTap;
  final Widget? rightButtonChild;
  final Widget? footer;
  final Widget? cancelButton;
  final Widget? deleteButton;
  final Widget title;
  final Widget confirmTitle;

  ShowLockOverlayArguments({
    required this.screenLockConfig,
    required this.inputButtonConfig,
    required this.inputSecretsConfig,
    this.canCancel = true,
    this.confirmMode = false,
    this.digits = 9,
    this.maxRetries = 0,
    this.lockController,
    this.onUnlocked,
    this.onError,
    this.onMaxRetries,
    this.onOpened,
    this.onConfirmed,
    this.onLeftButtonTap,
    this.rightButtonChild,
    this.footer,
    this.cancelButton,
    this.deleteButton,
    required this.title,
    required this.confirmTitle,
  });
}

Future<void>? showLockOverlay({
  required BuildContext context,
  required Future<bool> Function(String) onVerify,
  Object screenLockConfig = const Object(),
  Object secretsConfig = const Object(),
  Object inputButtonConfig = const Object(),
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
  Widget title = const Text('Please enter your passcode.'),
  Widget confirmTitle = const Text('Please enter confirm passcode.'),
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
