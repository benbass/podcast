import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/core/globals.dart';

import '../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../domain/entities/episode_entity.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.episode,
  });

  final EpisodeEntity episode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EpisodePlaybackCubit, EpisodePlaybackState>(
      builder: (context, state) {
        if (state.episode?.eId != episode.eId) {
          return PlayButtonActive(
            episode: episode,
          );
        } else {
          return const PlayButtonInactive();
        }
      },
    );
  }
}

class PlayButtonInactive extends StatelessWidget {
  const PlayButtonInactive({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.play_arrow_rounded,
      color: Colors.white24,
      size: 80,
    );
  }
}

class PlayButtonActive extends StatelessWidget {
  const PlayButtonActive({
    super.key,
    required this.episode,
  });

  final EpisodeEntity episode;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        final episodeToPlay = episodeBox.get(episode.id);
        BlocProvider.of<EpisodePlaybackCubit>(context).setPlaybackEpisode(
          episodeToPlay: episodeToPlay,
        );
        getIt<MyAudioHandler>().play();
      },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: const Icon(
        Icons.play_arrow_rounded,
        size: 80,
      ),
    );
  }
}
