import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';

import '../../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../../application/podcast_bloc/podcast_bloc.dart';
import '../../../domain/entities/podcast_entity.dart';
import '../../../helpers/core/utilities/image_provider.dart';
import '../../../helpers/player/audiohandler.dart';
import '../../../injection.dart';
import '../../custom_widgets/page_transition.dart';
import '../../episode_details_page/episode_details_page.dart';
import '../audioplayer_overlays.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({
    super.key,
  });

  final double kPlayerHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    final episode = context.read<EpisodePlaybackCubit>().state.episode;
    final podcast = context.read<EpisodePlaybackCubit>().state.podcast!;
    final episodes = context.read<EpisodePlaybackCubit>().state.episodes;
    String filterStatus =
        context.watch<PodcastBloc>().state.episodesFilterStatus.name;
    return Material(
      color: Colors.transparent,
      child: Container(
        height: kPlayerHeight,
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () async {
                // The EpisodeDetailsPage is a PageView depending on a specific list of episodes.
                // If user called a different podcast after tapping on Play, the episode being played doesn't exist for this podcast.
                // We reset the PodcastBloc state with the podcast the playback episode belongs to.
                // Once done, we can navigate to the EpisodeDetailsPage.
                await _resetPodcast(
                  context: context,
                  podcast: podcast,
                  filterStatus: filterStatus,
                );
                removeOverlayPlayerMin();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    ScaleRoute(
                      page: EpisodeDetailsPage(
                        initialEpisode: episode,
                        episodes: episodes!,
                      ),
                    ),
                    ModalRoute.withName('/'),
                  );
                }
              },
              // set HitTestBehavior.opaque to enable the GestureDetector to receive events on the entire row and not only on the row's children
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  FutureBuilder<ImageProvider>(
                      future: MyImageProvider(
                              url: episode!.image.isNotEmpty
                                  ? episode.image
                                  : podcast.artworkFilePath != null
                                      ? podcast.artworkFilePath!
                                      : podcast.artwork)
                          .imageProvider,
                      builder: (BuildContext context,
                          AsyncSnapshot<ImageProvider> snapshot) {
                        final ImageProvider imageProvider = snapshot.hasData
                            ? snapshot.data!
                            : const AssetImage('assets/placeholder.png');
                        return Container(
                          height: kPlayerHeight,
                          width: kPlayerHeight,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        );
                      }),
                  const SizedBox(
                    width: 4,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: 20,
                        width: MediaQuery.of(context).size.width - 170,
                        child: Text(
                          podcast.title,
                        ),
                      ),
                      StreamBuilder<Duration>(
                        stream: getIt<MyAudioHandler>().player.positionStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final currentDuration = snapshot.data!;
                            final totalDuration =
                                Duration(seconds: episode.duration!);
                            final progress = currentDuration.inMilliseconds /
                                totalDuration.inMilliseconds;
                            return SizedBox(
                              height: 6,
                              width: MediaQuery.of(context).size.width - 170,
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                backgroundColor: const Color(0xFFCBD4C2),
                                color: const Color(0xFF202531),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const Icon(Icons.error, color: Colors.red);
                          } else {
                            return const CircularProgressIndicator(); // loading
                          }
                        },
                      ),
                      SizedBox(
                        height: 20,
                        width: MediaQuery.of(context).size.width - 170,
                        child: Marquee(
                          text: episode.title,
                          //style: const TextStyle(color: Colors.white),
                          scrollAxis: Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          blankSpace: 120.0,
                          velocity: 40.0,
                          pauseAfterRound: const Duration(seconds: 3),
                          startPadding: 0.0,
                          accelerationDuration: const Duration(seconds: 1),
                          accelerationCurve: Curves.linear,
                          decelerationDuration:
                              const Duration(milliseconds: 500),
                          decelerationCurve: Curves.easeOut,
                        ),
                      ),
                    ],
                  ),
                ],
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
          ],
        ),
      ),
    );
  }

  _resetPodcast({
    required BuildContext context,
    required PodcastEntity podcast,
    required String filterStatus,
  }) async {
    final podcastBloc = BlocProvider.of<PodcastBloc>(context);
    // Remove filterText, if any:
    podcastBloc.add(
      ToggleEpisodesFilterStatusEvent(
        filterStatus: filterStatus,
        filterText: "",
      ),
    );
    // Reset podcast
    if (context.mounted) {
      podcastBloc.add(PodcastTappedEvent(podcast: podcast));
    }
  }
}
