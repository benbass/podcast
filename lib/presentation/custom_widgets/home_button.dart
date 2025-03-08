import 'package:flutter/material.dart';
import 'package:podcast/presentation/custom_widgets/page_transition.dart';

import '../subscribed_podcasts/subscribed_podcasts_page.dart';

class MyHomeButton extends StatelessWidget {
  const MyHomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          ScaleRoute(
            page: const SubscribedPodcastsPage(),
          ),
        );
      },
      icon: const Icon(Icons.home_rounded),
    );
  }
}
