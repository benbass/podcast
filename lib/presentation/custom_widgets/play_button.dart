import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../core/globals.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/podcast_entity.dart';
import '../../helpers/core/connectivity_manager.dart';
import '../../helpers/notifications/utilities_notifications.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';
import '../audioplayer_overlays/audioplayer_overlays.dart';
import 'dialogs/failure_dialog.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.episode,
    required this.podcast,
  });

  final EpisodeEntity episode;
  final PodcastEntity podcast;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EpisodePlaybackCubit, Map<PodcastEntity, EpisodeEntity>?>(
      builder: (context, state) {
        if (state?.values.first.eId != episode.eId) {
          return PlayButtonActive(episode: episode, podcast: podcast);
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
    required this.podcast,
  });

  final EpisodeEntity episode;
  final PodcastEntity podcast;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final currentPosition =
            getIt<MyAudioHandler>().player.position.inSeconds;
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
          removeOverlay();
          // source error?
          try {
            if (context.mounted) {
              // Save position of previous episode before changing to new one
              if (BlocProvider.of<EpisodePlaybackCubit>(context).state !=
                  null) {
                final previousEpisode =
                    BlocProvider.of<EpisodePlaybackCubit>(context).state!.values.first;
                previousEpisode.position = currentPosition;
                episodeBox.put(previousEpisode);
              }
            }

            await getIt<MyAudioHandler>().player.setUrl(filePath);
            getIt<MyAudioHandler>().play();
            if (episode.position > 0) {
              getIt<MyAudioHandler>()
                  .player
                  .seek(Duration(seconds: episode.position));
            }

            if (context.mounted) {
              BlocProvider.of<EpisodePlaybackCubit>(context)
                  .setPlaybackEpisode({podcast: episode});
              UtilitiesNotifications.createNotificationPlayback(context, false, episode.position);
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
