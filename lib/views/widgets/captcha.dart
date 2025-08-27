import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:katya/global/assets.dart';
import 'package:katya/global/values.dart';
import 'package:katya/views/widgets/lifecycle.dart';
import 'package:katya/views/widgets/loader/loading-indicator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class Captcha extends StatefulWidget {
  final String? baseUrl;
  final String? publicKey;
  final Function onVerified;

  const Captcha({
    Key? key,
    required this.baseUrl,
    required this.publicKey,
    required this.onVerified,
  }) : super(
          key: key,
        );

  @override
  CaptchaState createState() => CaptchaState();
}

class CaptchaState extends State<Captcha> with Lifecycle<Captcha> {
  WebViewController? controller;

  bool loading = true;

  CaptchaState();

  Future<String> _loadCaptchaHTML() async {
    final recaptchaHTML = await rootBundle.loadString(Assets.captchaHTML);
    return recaptchaHTML.replaceFirst(
      's%',
      widget.publicKey ?? Values.captchaMatrixSiteKey,
    );
  }

  // Matrix Public Key
  @override
  Widget build(BuildContext context) => Stack(
        children: [
          FutureBuilder<String>(
            future: _loadCaptchaHTML(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return WebViewWidget(
                  controller: WebViewController()
                    ..setJavaScriptMode(JavaScriptMode.unrestricted)
                    ..setBackgroundColor(Colors.transparent)
                    ..setNavigationDelegate(
                      NavigationDelegate(
                        onPageFinished: (String url) {
                          setState(() {
                            loading = false;
                          });
                        },
                      ),
                    )
                    ..addJavaScriptChannel(
                      'Captcha',
                      onMessageReceived: (JavaScriptMessage message) {
                        String token = message.message;
                        if (token.contains('verify')) {
                          token = token.substring(7);
                        }
                        widget.onVerified(token);
                      },
                    )
                    ..loadHtmlString(snapshot.data!),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          Visibility(
            visible: loading,
            child: Center(
              child: LoadingIndicator(loading: loading),
            ),
          ),
        ],
      );
}
