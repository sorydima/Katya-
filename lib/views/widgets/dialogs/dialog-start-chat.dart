import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:katya/global/libs/matrix/auth.dart';
import 'package:katya/global/strings.dart';
import 'package:katya/store/auth/actions.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/user/model.dart';
import 'package:katya/utils/theme_compatibility.dart';
import 'package:katya/views/widgets/buttons/button-text.dart';
import 'package:redux/redux.dart';

class DialogStartChat extends StatelessWidget {
  const DialogStartChat({
    super.key,
    this.user,
    this.title = 'Try chatting',
    this.content,
    this.action,
    this.onCancel,
    this.onStartChat,
  });

  final User? user;
  final String title;
  final String? content;
  final String? action;
  final Function? onCancel;
  final Function? onStartChat;

  @override
  Widget build(BuildContext context) {
    bool creating = false;

    return StatefulBuilder(
      builder: (context, setState) {
        final double width = MediaQuery.of(context).size.width;

        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(title),
          contentPadding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: 12,
          ),
          children: <Widget>[
            Text(
              content ?? Strings.confirmAttemptChat,
            ),
            Container(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ButtonText(
                    textWidget: Text(
                      Strings.buttonCancel,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    disabled: creating,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  ButtonText(
                    textWidget: Text(
                      action ?? Strings.buttonStartChat,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    loading: creating,
                    disabled: creating,
                    onPressed: () async {
                      setState(() {
                        creating = true;
                      });
                      if (onStartChat != null) {
                        await onStartChat!();
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}

class Props extends Equatable {
  final bool completed;
  final String? publicKey;

  final Function onCompleteCaptcha;

  const Props({
    required this.completed,
    required this.publicKey,
    required this.onCompleteCaptcha,
  });

  static Props mapStateToProps(Store<AppState> store) => Props(
        completed: store.state.authStore.captcha,
        publicKey: () {
          return store.state.authStore.interactiveAuths['params'][MatrixAuthTypes.RECAPTCHA]['public_key'];
        }(),
        onCompleteCaptcha: (String token, {required BuildContext context}) async {
          await store.dispatch(updateCredential(
            type: MatrixAuthTypes.RECAPTCHA,
            value: token,
          ));
          await store.dispatch(toggleCaptcha(completed: true));
          Navigator.of(context).pop();
        },
      );

  @override
  List<Object?> get props => [
        completed,
        publicKey,
      ];
}
