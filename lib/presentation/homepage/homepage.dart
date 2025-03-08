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

    // Listen for player state changes (e.g., playing, paused, buffering)
    getItI<MyAudioHandler>().player.playerStateStream.listen((playerState) {
      final processingState = playerState.processingState;

      if( processingState == ProcessingState.completed){
        getItI<MyAudioHandler>().stop();
        removeOverlay();
        BlocProvider.of<EpisodePlaybackCubit>(context)
            .setPlaybackEpisode(null);
      }
    });

    void navigateToSubscribedPodcastsPage() {
      Navigator.push(
          context,
          ScaleRoute(
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
