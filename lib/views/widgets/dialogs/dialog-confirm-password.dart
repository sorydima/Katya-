// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:katya/global/colors.dart';
import 'package:katya/global/dimensions.dart';
import 'package:katya/global/strings.dart';
import 'package:katya/views/widgets/loader/loading-indicator.dart';
import 'package:katya/utils/theme_compatibility.dart';

class DialogConfirmPassword extends HookWidget {
  const DialogConfirmPassword({
    Key? key,
    required this.title,
    required this.content,
    this.checkValid,
    this.checkLoading,
    this.onCancel,
    this.onConfirm,
    this.onChangePassword,
  }) : super(key: key);

  final Function? checkValid;
  final Function? checkLoading;

  final String title;
  final String content;

  final Function? onCancel;
  final Function? onConfirm;
  final Function? onChangePassword;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double defaultWidgetScaling = width * 0.725;

    final validLocal = useState(false);
    final loadingLocal = useState(false);

    final valid = (checkValid?.call() ?? false) || validLocal.value;
    final loading = (checkLoading?.call() ?? false) || loadingLocal.value;

    return SimpleDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titlePadding: EdgeInsets.only(
        left: 24,
        right: 16,
        top: 16,
        bottom: 16,
      ),
      contentPadding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
      ),
      title: Text(title),
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: defaultWidgetScaling,
              margin: const EdgeInsets.only(
                top: 16,
                bottom: 16,
                left: 8,
              ),
              child: Text(
                content,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            Container(
              width: defaultWidgetScaling,
              height: Dimensions.inputHeight,
              margin: const EdgeInsets.only(
                bottom: 32,
              ),
              constraints: BoxConstraints(
                minWidth: Dimensions.inputWidthMin,
                maxWidth: Dimensions.inputWidthMax,
              ),
              child: TextField(
                onChanged: (password) {
                  onChangePassword?.call(password);

                  validLocal.value = password.isNotEmpty;
                },
                obscureText: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(
                    left: 20,
                    top: 32,
                    bottom: 32,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  labelText: Strings.labelPassword,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              onPressed: !loading ? () => onCancel?.call() : null,
              child: Text(
                Strings.buttonCancel,
              ),
            ),
            TextButton(
              onPressed: !valid
                  ? null
                  : () {
                      onConfirm?.call();
                      loadingLocal.value = true;
                    },
              child: !loading
                  ? Text(Strings.buttonConfirmFormal,
                      style: TextStyle(
                        color: valid
                            ? Theme.of(context).primaryColor
                            : Color(AppColors.greyDisabled),
                      ))
                  : LoadingIndicator(),
            ),
          ],
        )
      ],
    );
  }
}
