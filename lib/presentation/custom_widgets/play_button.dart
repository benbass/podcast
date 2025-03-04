import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../application/episode_playback_url/episode_playback_url_cubit.dart';
import '../../domain/entities/episode_entity.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';
import '../audioplayer_overlays/audioplayer_overlays.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.episode,
    required this.podcastTitle,
  });

  final EpisodeEntity episode;
  final String podcastTitle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EpisodePlaybackUrlCubit, String>(
      builder: (context, state) {
        if (state != episode.enclosureUrl) {
          return StreamBuilder<PlayerState>(
              stream: getItI<MyAudioHandler>()
                  .player
                  .playerStateStream,
              builder: (context, stream) {
                final isPlaying = stream.data?.playing;

                return IconButton(
                  onPressed: () async {
                    if (isPlaying == true) {
                      // Only if player is playing we have an overlay (from current playback) that we can remove
                      removeOverlay();
                    }

                    // source error?
                    try {
                      await getItI<MyAudioHandler>()
                          .player
                          .setUrl(episode.enclosureUrl);
                      getItI<MyAudioHandler>().play();

                      // We need to wait for the previous overlayEntry, if any, to be removed before we can insert the new one
                      Future.delayed(
                          const Duration(seconds: 2));
                      if (context.mounted) {
                        BlocProvider.of<
                            EpisodePlaybackUrlCubit>(
                            context)
                            .setPlaybackEpisodeUrl(
                            episode.enclosureUrl);
                        showOverlayPlayerMin(context,
                            episode, podcastTitle);
                      }
                    } on PlayerException {
                      if (context.mounted) {
                        showOverlayError(context,
                            "Error: No valid file exists under the requested url.");
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
              });
        } else {
          return const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white24,
            size: 80,
          );
        }
      },
    );
  }
}