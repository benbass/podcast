import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcast/presentation/episode_details_page/widgets/playback_position_slider.dart';

import '../../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../../domain/entities/episode_entity.dart';
import '../../../helpers/player/audiohandler.dart';
import '../../../injection.dart';
import '../../audioplayer_overlays/audioplayer_overlays.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      height: MediaQuery.of(context).size.height / 7,
      constraints: const BoxConstraints(minHeight: 150),
      child: Center(
        child: Column(
          children: [
            BlocBuilder<EpisodePlaybackCubit, EpisodeEntity?>(
              builder: (context, state) {
                if (state != null) {
                  return PlaybackPositionSlider(episode: state);
                } else {
                  return const SizedBox.shrink();
                }
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
                      getIt<MyAudioHandler>().seekBackward();
                    },
                    icon: const Icon(
                      Icons.fast_rewind_rounded,
                      size: 40,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      getIt<MyAudioHandler>().stop().then((_) {
                        if (context.mounted) {
                          BlocProvider.of<EpisodePlaybackCubit>(context)
                              .setPlaybackEpisode(null);
                          removeOverlay();
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.stop_rounded,
                      size: 50,
                    ),
                  ),
                  StreamBuilder<PlayerState>(
                      stream: getIt<MyAudioHandler>().player.playerStateStream,
                      builder: (context, stream) {
                        final isPlaying = stream.data?.playing;
                        return IconButton(
                          onPressed: () {
                            getIt<MyAudioHandler>().handlePlayPause();
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
                      getIt<MyAudioHandler>().seekForward();
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
