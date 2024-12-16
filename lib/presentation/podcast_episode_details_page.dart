import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcast/domain/entities/episode_entity.dart';

import '../application/podcast_episode_url/current_url_cubit.dart';
import '../helpers/core/format_duration.dart';
import '../helpers/core/format_pubdate_string.dart';
import '../helpers/player/audiohandler.dart';
import '../injection.dart';
import 'audioplayer_overlay.dart';

class PodcastEpisodeDetailsPage extends StatelessWidget {
  final EpisodeEntity episode;
  final String title;

  const PodcastEpisodeDetailsPage({
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
        if (sl<MyAudioHandler>().player.playing && overlayEntry == null) {
          showOverlayPlayerMin(context, episode, title);
        }
        // We don't pop immediately (it causes an exception): we use a scheduler
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pop();
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("$title: ${episode.title}"),
          leading: IconButton(
            onPressed: () {
              if (sl<MyAudioHandler>().player.playing && overlayEntry == null) {
                showOverlayPlayerMin(context, episode, title);
              }

              Navigator.of(context).pop();
            },
            icon: const BackButtonIcon(),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 4,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: episode.image != ""
                          ? NetworkImage(episode.image)
                          : const AssetImage("assets/placeholder.png"),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Center(
                        child: FadeInImage(
                          fadeOutDuration: const Duration(milliseconds: 100),
                          fadeInDuration: const Duration(milliseconds: 200),
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "assets/placeholder.png",
                              fit: BoxFit.cover,
                              //height: 300,
                              //width: 300,
                            );
                          },
                          //height: 300,
                          //width: 300,
                          fit: BoxFit.cover,
                          placeholder:
                              const AssetImage('assets/placeholder.png'),
                          image: NetworkImage(episode.image),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(episode.title),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatTimestamp(episode.datePublished)),
                          Text(episode.duration! == 0
                              ? ""
                              : formatIntDuration(episode.duration!)),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 3,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 50.0),
                            child: Text(
                              episode.description,
                              style: const TextStyle(
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
                bottom: MediaQuery.of(context).padding.bottom,
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
      ),
    );
  }
}
