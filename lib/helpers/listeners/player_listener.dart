import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../injection.dart';
import '../../presentation/audioplayer_overlays/audioplayer_overlays.dart';
import '../player/audiohandler.dart';

void listenToPlayer(BuildContext context){
  getIt<MyAudioHandler>().player.playerStateStream.listen((playerState) {
    final processingState = playerState.processingState;

    if (processingState == ProcessingState.completed) {
      getIt<MyAudioHandler>().stop();
      removeOverlay();
      if (context.mounted) {
        BlocProvider.of<EpisodePlaybackCubit>(context)
            .setPlaybackEpisode(null);
      }
    }
  });
}