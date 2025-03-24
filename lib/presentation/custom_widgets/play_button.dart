import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/podcast_entity.dart';
import '../../helpers/core/connectivity_manager.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';
import '../audioplayer_overlays/audioplayer_overlays.dart';
import 'failure_dialog.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.episode,
    required this.podcast,
    required this.podcastTitle,
  });

  final EpisodeEntity episode;
  final PodcastEntity podcast;
  final String podcastTitle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EpisodePlaybackCubit, EpisodeEntity?>(
      builder: (context, state) {
        if (state?.id != episode.id) {
          return PlayButtonActive(episode: episode);
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
      onPressed: () async {
        final String connectionType =
            await getIt<ConnectivityManager>().getConnectionTypeAsString();
        String filePath = episode.filePath ?? episode.enclosureUrl;
        if (connectionType == 'none' && filePath == episode.enclosureUrl) {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) =>
                  const FailureDialog(message: "No internet connection!"),
            );
          }
        } else {
          // source error?
          try {
            await getIt<MyAudioHandler>().player.setUrl(filePath);
            getIt<MyAudioHandler>().play();

            if (context.mounted) {
              BlocProvider.of<EpisodePlaybackCubit>(context)
                  .setPlaybackEpisode(episode);
              //showOverlayPlayerMin(context, episode, podcast, podcastTitle);
            }
          } on PlayerException {
            if (context.mounted) {
              showOverlayError(context,
                  "Error: No valid file exists under the requested url.");
            }
          }
        }
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
