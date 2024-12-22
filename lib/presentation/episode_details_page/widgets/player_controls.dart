import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../../application/episode_playback_url/episode_playback_url_cubit.dart';
import '../../../domain/entities/episode_entity.dart';
import '../../../helpers/core/format_duration.dart';
import '../../../helpers/player/audiohandler.dart';
import '../../../injection.dart';
import '../../audioplayer_overlays/audioplayer_overlays.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
    required this.episode,
  });

  final EpisodeEntity episode;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      height: MediaQuery.of(context).size.height / 7,
      constraints: const BoxConstraints(minHeight: 150),
      child: Center(
        child: Column(
          children: [
            StreamBuilder<Duration>(
              stream: sl<MyAudioHandler>().player.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final Duration totalDuration =
                    Duration(seconds: episode.duration!);
                final Duration remainingDuration = totalDuration - position;
                String formattedRemainingDuration =
                    formatRemainingDuration(remainingDuration);
                return Column(
                  children: [
                    Slider(
                      activeColor: Theme.of(context).colorScheme.onPrimary,
                      inactiveColor: Theme.of(context).colorScheme.primary,
                      value: position.inSeconds.toDouble(),
                      min: 0.0,
                      max: sl<MyAudioHandler>()
                              .player
                              .duration
                              ?.inSeconds
                              .toDouble() ??
                          0.0,
                      onChanged: (value) => sl<MyAudioHandler>()
                          .player
                          .seek(Duration(seconds: value.toInt())),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDurationDuration(position),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            totalDuration == Duration.zero
                                ? ""
                                : formattedRemainingDuration,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.skip_previous_rounded,
                      size: 40,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      sl<MyAudioHandler>().seekBackward();
                    },
                    icon: const Icon(
                      Icons.fast_rewind_rounded,
                      size: 40,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      sl<MyAudioHandler>().stop();
                      BlocProvider.of<EpisodePlaybackUrlCubit>(context)
                          .setPlaybackEpisodeUrl("");
                      removeOverlay();
                    },
                    icon: const Icon(
                      Icons.stop_rounded,
                      size: 50,
                    ),
                  ),
                  StreamBuilder<PlayerState>(
                      stream: sl<MyAudioHandler>().player.playerStateStream,
                      builder: (context, stream) {
                        final isPlaying = stream.data?.playing;
                        return IconButton(
                          onPressed: () {
                            sl<MyAudioHandler>().handlePlayPause();
                          },
                          icon: Icon(
                            isPlaying == true
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 50,
                          ),
                        );
                      }),
                  IconButton(
                    onPressed: () {
                      sl<MyAudioHandler>().seekForward();
                    },
                    icon: const Icon(
                      Icons.fast_forward_rounded,
                      size: 40,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.skip_next_rounded,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
