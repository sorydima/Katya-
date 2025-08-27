import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:redux/redux.dart';
import 'package:katya/global/assets.dart';
import 'package:katya/global/dimensions.dart';
import 'package:katya/global/strings.dart';
import 'package:katya/store/auth/actions.dart';
import 'package:katya/store/index.dart';
import 'package:katya/views/widgets/input/text-field-secure.dart';
import 'package:katya/utils/theme_compatibility.dart';

class PasswordResetStep extends StatefulWidget {
  const PasswordResetStep({Key? key}) : super(key: key);

  @override
  PasswordResetStepState createState() => PasswordResetStepState();
}

class PasswordResetStepState extends State<PasswordResetStep> {
  PasswordResetStepState();

  bool visibility = false;

  FocusNode confirmFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    onMounted();
  }

  void onMounted() {
    final store = StoreProvider.of<AppState>(context);
    passwordController.text = store.state.authStore.password;
    confirmController.text = store.state.authStore.passwordConfirm;
  }

  @override
  void dispose() {
    confirmFocusNode.dispose();
    passwordFocusNode.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StoreConnector<AppState, _Props>(
        distinct: true,
        converter: (Store<AppState> store) => _Props.mapStateToProps(store),
        builder: (context, props) {
          final double width = MediaQuery.of(context).size.width;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Flexible(
                flex: 4,
                fit: FlexFit.tight,
                child: Container(
                  width: width * 0.65,
                  padding: EdgeInsets.only(bottom: 8),
                  constraints: BoxConstraints(
                    maxHeight: Dimensions.mediaSizeMax,
                    maxWidth: Dimensions.mediaSizeMax,
                  ),
                  child: SvgPicture.asset(
                    Assets.heroSignupPassword,
                    semanticsLabel: 'User thinking up a password in a swirl of wind',
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
                        Strings.contentPasswordRecommendation,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Create a password',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: TextFieldSecure(
                  label: 'Password',
                  focusNode: passwordFocusNode,
                  controller: passwordController,
                  obscureText: !visibility,
                  onChanged: (text) {
                    props.onChangePassword(text);
                  },
                  onSubmitted: (String value) {
                    FocusScope.of(context).requestFocus(confirmFocusNode);
                  },
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(confirmFocusNode);
                  },
                  suffix: GestureDetector(
                    onTap: () {
                      if (!passwordFocusNode.hasFocus) {
                        // Unfocus all focus nodes
                        passwordFocusNode.unfocus();

                        // Disable text field's focus node request
                        passwordFocusNode.canRequestFocus = false;
                      }

                      // Do your stuff
                      setState(() {
                        visibility = !visibility;
                      });

                      if (!passwordFocusNode.hasFocus) {
                        //Enable the text field's focus node request after some delay
                        Future.delayed(Duration(milliseconds: 100), () {
                          passwordFocusNode.canRequestFocus = true;
                        });
                      }
                    },
                    child: Icon(
                      visibility ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              Container(
                  padding: EdgeInsets.symmetric(
                vertical: 8,
              )),
              Flexible(
                flex: 1,
                child: TextFieldSecure(
                  label: 'Confirm Password',
                  focusNode: confirmFocusNode,
                  controller: confirmController,
                  obscureText: !visibility,
                  onChanged: (text) {
                    props.onChangePasswordConfirm(text);
                  },
                  onSubmitted: (String value) {
                    confirmFocusNode.unfocus();
                  },
                  onEditingComplete: () {
                    props.onChangePasswordConfirm(props.passwordConfirm);
                  },
                  suffix: Visibility(
                    visible: props.isPasswordValid,
                    child: Container(
                      width: 12,
                      height: 12,
                      margin: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
}

class _Props extends Equatable {
  final String password;
  final String passwordConfirm;
  final bool isPasswordValid;

  final Function onChangePassword;
  final Function onChangePasswordConfirm;

  const _Props({
    required this.password,
    required this.passwordConfirm,
    required this.isPasswordValid,
    required this.onChangePassword,
    required this.onChangePasswordConfirm,
  });

  @override
  List<Object> get props => [
        password,
        passwordConfirm,
        isPasswordValid,
      ];

  static _Props mapStateToProps(Store<AppState> store) => _Props(
        password: store.state.authStore.password,
        passwordConfirm: store.state.authStore.passwordConfirm,
        isPasswordValid: store.state.authStore.isPasswordValid,
        onChangePassword: (String text) {
          store.dispatch(setPassword(password: text));
        },
        onChangePasswordConfirm: (String text) {
          store.dispatch(setPasswordConfirm(password: text));
        },
      );
}
