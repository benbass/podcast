import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyWebView extends StatelessWidget {
  final String url;
  const MyWebView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    WebViewController webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: WebViewWidget(
          controller: webViewController
            ..loadRequest(
              Uri.parse(url),
            ),
        ),
      ),
    );
  }
}
