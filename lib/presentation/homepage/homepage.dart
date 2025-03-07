import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../application/episode_playback/episode_playback_cubit.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';
import '../audioplayer_overlays/audioplayer_overlays.dart';
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

    // We wrap the app in a just_audio stream builder so we can listen to player states whatever page is called
    return StreamBuilder<ProcessingState>(
        stream: getItI<MyAudioHandler>().myPlayerProcessingStateStream,
        builder: (context, snapshot) {
          final processingState = snapshot.data;
          if (processingState == ProcessingState.completed) {
            getItI<MyAudioHandler>().stop();
            removeOverlay();
            BlocProvider.of<EpisodePlaybackCubit>(context)
                .setPlaybackEpisode(null);
          }
          return Center(
            ///TODO: Replace with app logo
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset("assets/placeholder.png"),
            ),
          );
        });
  }
}
