import 'package:flutter/material.dart';

import '../custom_widgets/page_transition.dart';
import '../subscribed_podcasts/subscribed_podcasts_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    void navigateToSubscribedPodcastsPage() {
      Navigator.push(
          context,
          SlideRouteWithCurve(
            page: const SubscribedPodcastsPage(),
          ));
    }

    Future.delayed(
        const Duration(seconds: 1), () => navigateToSubscribedPodcastsPage());

    return Center(
      ///TODO: Replace with app logo
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Image.asset("assets/placeholder.png"),
      ),
    );
  }
}
