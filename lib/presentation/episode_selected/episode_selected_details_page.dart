import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcast/domain/entities/episode_entity.dart';

import '../../application/podcast_episode_url/current_url_cubit.dart';
import '../../helpers/core/format_duration.dart';
import '../../helpers/core/format_pubdate_string.dart';
import '../../helpers/core/get_android_version.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';
import '../audioplayer_overlays/audioplayer_overlays.dart';
import '../custom_widgets/flexible_space.dart';

class EpisodeSelectedDetailsPage extends StatelessWidget {
  final EpisodeEntity episode;
  final String title;

  const EpisodeSelectedDetailsPage({
    super.key,
    required this.episode,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // We wrap this widget in PopScope so we can apply a method on the OS back-button:
    // we need to rebuild the overlay!
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        if (sl<MyAudioHandler>().player.processingState ==
                ProcessingState.ready &&
            overlayEntry == null) {
          showOverlayPlayerMin(context, episode, title);
        }
        // We don't pop immediately (it causes an exception): we use a scheduler
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pop();
        });
      },
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  FlexibleSpace(
                    podcast: null,
                    episode: episode,
                    title: title,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatTimestamp(episode.datePublished)),
                          Text(episode.duration! == 0
                              ? ""
                              : formatIntDuration(episode.duration!)),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 170.0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        episode.description,
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
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
                            final Duration remainingDuration =
                                totalDuration - position;
                            String formattedRemainingDuration =
                                formatRemainingDuration(remainingDuration);
                            return Column(
                              children: [
                                Slider(
                                  activeColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  inactiveColor:
                                      Theme.of(context).colorScheme.primary,
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                  BlocProvider.of<CurrentUrlCubit>(context)
                                      .setCurrentEpisodeUrl("");
                                  removeOverlay();
                                },
                                icon: const Icon(
                                  Icons.stop_rounded,
                                  size: 50,
                                ),
                              ),
                              StreamBuilder<PlayerState>(
                                  stream: sl<MyAudioHandler>()
                                      .player
                                      .playerStateStream,
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
                ))
          ],
        ),
        bottomNavigationBar: Platform.isAndroid && androidVersion > 14
            ? Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                height: MediaQuery.of(context).padding.bottom,
              )
            : null,
      ),
    );
  }
}
