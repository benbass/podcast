import 'package:flutter/material.dart';

import '../../custom_widgets/webview.dart';

class PodcastWebsiteLink extends StatelessWidget {
  const PodcastWebsiteLink({
    super.key,
    required this.link,
  });

  final String link;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MyWebView(
              url: link,
            ),
          ),
        );
      },
      child: const Text(
        "Podcast website",
        style: TextStyle(
          decoration: TextDecoration.underline,
          decorationColor: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }
}