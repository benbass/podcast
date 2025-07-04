import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/core/globals.dart';
import '../../application/playback/playback_cubit/playback_cubit.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/podcast_entity.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.episode,
    required this.episodeIndex,
    required this.playlist,
    required this.podcast,
  });

  final EpisodeEntity episode;
  final int episodeIndex;
  final List<EpisodeEntity> playlist;
  final PodcastEntity podcast;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackCubit, PlaybackState>(
      builder: (context, state) {
        if (state.episode?.eId != episode.eId) {
          return PlayButtonActive(
            episode: episode,
            episodeIndex: episodeIndex,
            playlist: playlist,
            podcast: podcast,
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
    required this.episodeIndex,
    required this.playlist,
    required this.podcast,
  });

  final EpisodeEntity episode;
  final int episodeIndex;
  final List<EpisodeEntity> playlist;
  final PodcastEntity podcast;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        final previousEpisode =
            context.read<PlaybackCubit>().state.episode;
        if (previousEpisode != null) {
          previousEpisode.position =
              getIt<MyAudioHandler>().player.position.inSeconds;
          episodeBox.put(previousEpisode);
        }
        final bool? autoplayEnabled = podcast.persistentSettings.target?.autoplayEnabled; // Null when podcast is not subscribed
        BlocProvider.of<PlaybackCubit>(context).onPlay(
          origin: podcast.feedId.toString(),
          episode: episode,
          playlist: playlist,
          isAutoplayEnabled: autoplayEnabled ?? false,
          isUserPlaylist: false,
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
