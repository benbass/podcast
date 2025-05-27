import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcast/presentation/episode_details_page/widgets/playback_position_slider.dart';

import '../../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../../domain/entities/episode_entity.dart';
import '../../../domain/entities/podcast_entity.dart';
import '../../../helpers/notifications/utilities_notifications.dart';
import '../../../helpers/player/audiohandler.dart';
import '../../../injection.dart';

class PlayerControls extends StatelessWidget {
  final PageController? pageController;
  final List<EpisodeEntity> episodeListForNav;
  final int currentIndexInListForNav;
  final PodcastEntity podcast;
  const PlayerControls({
    super.key,
    this.pageController,
    required this.episodeListForNav,
    required this.currentIndexInListForNav,
    required this.podcast,
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
            BlocBuilder<EpisodePlaybackCubit,
                Map<PodcastEntity, EpisodeEntity>?>(
              builder: (context, state) {
                if (state != null) {
                  return PlaybackPositionSlider(episode: state.values.first);
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
                    onPressed: () async {
                      if (currentIndexInListForNav > 0) {
                        final previousEpisode =
                            episodeListForNav[currentIndexInListForNav - 1];
                        await getIt<MyAudioHandler>().handlePlayButtonPressed(context, previousEpisode, podcast);
                        Future.delayed(const Duration(milliseconds: 50), () {
                          if (pageController != null && pageController!.hasClients) {
                            pageController!.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        });
                      }
                    },
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
                      getIt<MyAudioHandler>().stop();

                      BlocProvider.of<EpisodePlaybackCubit>(context)
                          .setPlaybackEpisode(null);
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
                            UtilitiesNotifications.cancelNotificationPlayback();
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
                    onPressed: () async {
                      if(currentIndexInListForNav < episodeListForNav.length - 1) {
                        final nextEpisode = episodeListForNav[currentIndexInListForNav + 1];
                        await getIt<MyAudioHandler>().handlePlayButtonPressed(context, nextEpisode, podcast);
                        Future.delayed(const Duration(milliseconds: 50), () {
                          if (pageController != null && pageController!.hasClients) {
                            pageController!.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        });
                      }
                    },
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
