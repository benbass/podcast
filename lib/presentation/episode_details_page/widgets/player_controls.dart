import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcast/presentation/episode_details_page/widgets/playback_position_slider.dart';

import '../../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../../domain/entities/podcast_entity.dart';
import '../../../helpers/notifications/utilities_notifications.dart';
import '../../../helpers/player/audiohandler.dart';
import '../../../injection.dart';

class PlayerControls extends StatelessWidget {
  final PageController? pageController;
  final PodcastEntity podcast;
  const PlayerControls({
    super.key,
    this.pageController,
    required this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return BlocBuilder<EpisodePlaybackCubit, EpisodePlaybackState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
            color: Colors.white12,
            boxShadow: [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 2.0,
                offset: Offset(0, 2),
                spreadRadius: 1.0,
              ),
            ],
          ),
          height: MediaQuery.of(context).size.height * 0.17,
          constraints: const BoxConstraints(minHeight: 170),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PlaybackPositionSlider(episode: state.episode!),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: state.currentIndexInPlaylist == 0
                            ? null
                            : () async {
                                // playPrevious() (and playNext()) handle the EpisodePlaybackCubit
                                // update that will return true if success or false.
                                // If true, the audioHandler will handle the playback
                                // of the new episode.
                                bool result = await getIt<MyAudioHandler>()
                                    .playPrevious();
                                if (result) {
                                  Future.delayed(
                                      const Duration(milliseconds: 50), () {
                                    if (pageController != null &&
                                        pageController!.hasClients) {
                                      pageController!.previousPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  });
                                }
                              },
                        icon: Icon(
                          Icons.skip_previous_rounded,
                          size: 40,
                          color: state.currentIndexInPlaylist == 0
                              ? themeData.colorScheme.onPrimary
                                  .withValues(alpha: 0.5)
                              : themeData.colorScheme.onPrimary,
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
                        },
                        icon: const Icon(
                          Icons.stop_rounded,
                          size: 50,
                        ),
                      ),
                      StreamBuilder<PlayerState>(
                          stream:
                              getIt<MyAudioHandler>().player.playerStateStream,
                          builder: (context, stream) {
                            final isPlaying = stream.data?.playing;
                            return IconButton(
                              onPressed: () {
                                UtilitiesNotifications
                                    .cancelNotificationPlayback();
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
                        onPressed: state.currentIndexInPlaylist ==
                                state.episodes!.length - 1
                            ? null
                            : () async {
                                bool result =
                                    await getIt<MyAudioHandler>().playNext();
                                if (result) {
                                  Future.delayed(
                                      const Duration(milliseconds: 50), () {
                                    if (pageController != null &&
                                        pageController!.hasClients) {
                                      pageController!.nextPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  });
                                }
                              },
                        icon: Icon(
                          Icons.skip_next_rounded,
                          size: 40,
                          color: state.currentIndexInPlaylist ==
                                  state.episodes!.length - 1
                              ? themeData.colorScheme.onPrimary
                                  .withValues(alpha: 0.5)
                              : themeData.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
