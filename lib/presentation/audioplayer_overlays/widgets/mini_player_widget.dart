import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:podcast/application/episodes_cubit/episodes_cubit.dart';
import 'package:podcast/application/show_flagged_list/show_flagged_list_cubit.dart';
import 'package:podcast/domain/usecases/episode_usecases.dart';

import '../../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../../application/podcast_bloc/podcast_bloc.dart';
import '../../../domain/entities/episode_entity.dart';
import '../../../domain/entities/podcast_entity.dart';
import '../../../helpers/core/image_provider.dart';
import '../../../helpers/player/audiohandler.dart';
import '../../../injection.dart';
import '../../custom_widgets/page_transition.dart';
import '../../episode_details_page/episode_details_page.dart';

class MiniPlayerWidget extends StatelessWidget {
  final PodcastEntity podcast;
  const MiniPlayerWidget({
    super.key,
    required this.podcast,
  });

  final double kPlayerHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    final EpisodeEntity episode =
        BlocProvider.of<EpisodePlaybackCubit>(context).state!;
    bool areReadEpisodesVisible =
        context.watch<PodcastBloc>().state.areReadEpisodesVisible;
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
                // The EpisodeDetailsPage is a PageView depending on a list of episodes saved in EpisodesCubit state.
                // If user called a new list of episodes after clicking on Play, the current EpisodesCubit doesn't contain the episode being played.
                // (And the state of PodcastBloc also changed).
                // That's why we need to check this now and set the state of EpisodesCubit with the list of episodes that contains the episode being played.
                // We also set the PodcastBloc state with the podcast that was passed as the overlay was created.
                // Once done, we can navigate to the EpisodeDetailsPage.
                EpisodeEntity episodeToDisplay = episode;
                List<EpisodeEntity> currentEpisodes =
                    BlocProvider.of<EpisodesCubit>(context, listen: false)
                        .state;

                if (!currentEpisodes.contains(episodeToDisplay)) {
                  await _resetEpisodesAndPodcast(
                    context: context,
                    episodeToDisplay: episodeToDisplay,
                    areReadEpisodesVisible: areReadEpisodesVisible,
                  );
                }

                if (context.mounted) {
                  Navigator.of(context).push(
                    ScaleRoute(
                      page: EpisodeDetailsPage(
                        episode: episodeToDisplay,
                        podcast: podcast,
                      ),
                    ),
                  );
                }
              },
              // set HitTestBehavior.opaque to enable the GestureDetector to receive events on the entire row and not only on the row's children
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  FutureBuilder<ImageProvider>(
                      future: MyImageProvider(
                              url: episode.image.isNotEmpty
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

  _resetEpisodesAndPodcast({
    required BuildContext context,
    required EpisodeEntity episodeToDisplay,
    required bool areReadEpisodesVisible,
  }) async {
    List<EpisodeEntity> episodes = [];
    // Depending on value of flag, we want to get either the flagged or un-flagged episodes.
    String? flag = BlocProvider.of<ShowFlaggedListCubit>(context).state;
    if (flag != null) {
      final map =
          await getIt<EpisodeUseCases>().getFlaggedEpisodes(flag: flag).first;
      episodes = map.values.expand((episodes) => episodes).toList();
    } else {
      episodes = await getIt<EpisodeUseCases>()
          .getEpisodes(
            subscribed: podcast.subscribed,
            feedId: podcast.pId,
            podcastTitle: podcast.title,
            showRead: areReadEpisodesVisible,
            refresh: false,
          )
          .first;
    }

    episodeToDisplay =
        episodes.firstWhere((element) => element.eId == episodeToDisplay.eId);
    if (context.mounted) {
      BlocProvider.of<PodcastBloc>(context)
          .add(PodcastTappedEvent(podcast: podcast));
      BlocProvider.of<EpisodesCubit>(context).setEpisodes(episodes);
    }
  }
}
