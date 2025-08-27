import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:redux/redux.dart';
import 'package:katya/global/assets.dart';
import 'package:katya/global/colors.dart';
import 'package:katya/global/dimensions.dart';
import 'package:katya/global/libs/matrix/auth.dart';
import 'package:katya/global/print.dart';
import 'package:katya/global/strings.dart';
import 'package:katya/store/auth/actions.dart';
import 'package:katya/store/index.dart';
import 'package:katya/views/widgets/buttons/button-text.dart';
import 'package:katya/views/widgets/dialogs/dialog-captcha.dart';
import 'package:katya/views/widgets/dialogs/dialog-confirm.dart';
import 'package:katya/utils/theme_compatibility.dart';

class CaptchaStep extends StatefulWidget {
  const CaptchaStep({Key? key}) : super(key: key);

  @override
  CaptchaStepState createState() => CaptchaStepState();
}

class CaptchaStepState extends State<CaptchaStep> {
  final focusNode = FocusNode();

  onShowDialog(BuildContext context, _Props props) async {
    final store = StoreProvider.of<AppState>(context);
    final authSession = store.state.authStore.authSession;

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) => DialogCaptcha(
        key: Key(authSession!),
        hostname: props.hostname,
        publicKey: props.publicKey,
        onComplete: (String token) {
          props.onCompleteCaptcha(token);

          log.info('COMPLETED');
          Navigator.pop(dialogContext);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => StoreConnector<AppState, _Props>(
      distinct: true,
      converter: (Store<AppState> store) => _Props.mapStateToProps(store),
      builder: (context, props) {
        final double width = MediaQuery.of(context).size.width;

        return Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 6,
              child: Container(
                width: width * 0.75,
                constraints: BoxConstraints(
                  maxHeight: Dimensions.mediaSizeMax,
                  maxWidth: Dimensions.mediaSizeMax,
                ),
                child: SvgPicture.asset(
                  Assets.heroAcceptTerms,
                  semanticsLabel: Strings.labelTermsOfService,
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 8, top: 8),
                    child: Text(
                      Strings.contentCaptchaRequirement,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 24,
                        ),
                        child: Text(
                          'Confirm you\'re alive',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) => DialogConfirm(
                                title: Strings.titleDialogCaptcha,
                                content: Strings.contentCaptchaWarning,
                                onConfirm: () => Navigator.pop(dialogContext),
                                onDismiss: () => Navigator.pop(dialogContext),
                              ),
                            );
                          },
                          child: Container(
                            height: 20,
                            width: 20,
                            child: Icon(
                              Icons.info_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ButtonText(
                    text: !props.completed
                        ? Strings.buttonTextLoadCaptcha
                        : Strings.buttonTextConfirmed,
                    color: !props.completed
                        ? Color(AppColors.cyankatya)
                        : Color(AppColors.cyankatyaAlpha),
                    loading: props.loading,
                    disabled: props.completed,
                    onPressed: () => onShowDialog(context, props),
                  ),
                ],
              ),
            ),
          ],
        );
      });
}

class _Props extends Equatable {
  final bool loading;
  final bool completed;

  final String? hostname;
  final String? publicKey;

  final Function onCompleteCaptcha;

  const _Props({
    required this.loading,
    required this.completed,
    required this.hostname,
    required this.publicKey,
    required this.onCompleteCaptcha,
  });

  @override
  List<Object> get props => [
        loading,
        completed,
      ];

  static _Props mapStateToProps(Store<AppState> store) => _Props(
        loading: store.state.authStore.loading,
        completed: store.state.authStore.captcha,
        hostname: store.state.authStore.hostname,
        publicKey: () {
          return store.state.authStore.interactiveAuths['params'][MatrixAuthTypes.RECAPTCHA]
                  ['public_key'] ??
              '';
        }(),
        onCompleteCaptcha: (String token) async {
          await store.dispatch(updateCredential(
            type: MatrixAuthTypes.RECAPTCHA,
            value: token,
          ));
          await store.dispatch(toggleCaptcha(completed: true));
        },
      );
}
