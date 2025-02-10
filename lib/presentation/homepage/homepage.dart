import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/podcasts_bloc/podcasts_bloc.dart';
import '../custom_widgets/page_transition.dart';
import '../subscribed_podcasts/subscribed_podcasts_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<PodcastsBloc>(context).add(FetchSubscribedPodcastsEvent());

    void navigateToSubscribedPodcastsPage() {
      Navigator.push(
        context,
        SlideBottomRoute(
          page: const SubscribedPodcastsPage(),
        ),
      );
    }

    return BlocListener<PodcastsBloc, PodcastsState>(
        listener: (context, state) {
          if (state is SubscribedPodcastsFetchSuccessState) {
            Future.delayed(const Duration(seconds: 1),
                () => navigateToSubscribedPodcastsPage());
          }
        },
        child: Center(
          ///TODO: Replace with app logo
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset("assets/placeholder.png"),
          ),
        ));
  }
}
