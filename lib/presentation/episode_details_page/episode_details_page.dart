import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcast/application/podcast_bloc/podcast_bloc.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/presentation/custom_widgets/episode_actions_row.dart';
import 'package:podcast/presentation/episode_details_page/widgets/player_controls.dart';
import 'package:podcast/presentation/episodes_list_page/episodes_list_page.dart';

import '../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../domain/entities/podcast_entity.dart';
import '../../domain/usecases/episode_usecases.dart';
import '../../helpers/core/format_duration.dart';
import '../../helpers/core/format_pubdate_string.dart';
import '../../helpers/core/show_episode_actions_dialog.dart';
import '../../helpers/listeners/player_listener.dart';
import '../../injection.dart';
import '../audioplayer_overlays/audioplayer_overlays.dart';
import '../custom_widgets/failure_widget.dart';
import '../custom_widgets/flexible_space.dart';
import '../custom_widgets/page_transition.dart';
import 'widgets/podcast_website_link.dart';

class EpisodeDetailsPage extends StatelessWidget {
  final EpisodeEntity episode;

  const EpisodeDetailsPage({
    super.key,
    required this.episode,
  });

  @override
  Widget build(BuildContext context) {
    final podcastState =
        BlocProvider.of<PodcastBloc>(context, listen: false).state;

    // We wrap this widget in PopScope so we can apply a method on the OS back-button
    // where we handle the overlay!
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          if (getIt<PlayerStatesListener>().player.processingState ==
                  ProcessingState.ready &&
              overlayEntry == null) {
            showOverlayPlayerMin(context);
          }

          return;
        }
        Navigator.of(context).push(
          ScaleRoute(
            page: const EpisodesListPage(),
          ),
        );
      },
      child:
          BlocBuilder<EpisodePlaybackCubit, Map<PodcastEntity, EpisodeEntity>?>(
        builder: (context, episodePlaybackState) {
          episodePlaybackState != null &&
                  episodePlaybackState.values.first.eId == episode.eId
              ? removeOverlay()
              : null;
          return Scaffold(
            body: StreamBuilder(
                stream: getIt<EpisodeUseCases>().getEpisodes(
                  subscribed: podcastState.currentPodcast.subscribed,
                  feedId: podcastState.currentPodcast.pId,
                  podcastTitle: podcastState.currentPodcast.title,
                  filterStatus: podcastState.episodesFilterStatus.name,
                  refresh: false,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: buildFailureWidget(
                          message: 'Error loading the episodes'),
                    );
                  } else if (snapshot.hasData) {
                    final List<EpisodeEntity> episodes = snapshot.data!;
                    int indexOfInitial = episodes
                        .indexWhere((element) => element.eId == episode.eId);
                    return PageView.builder(
                        controller: PageController(initialPage: indexOfInitial),
                        onPageChanged: (index) async {
                          final ep = episodes[index];
                          if (getIt<PlayerStatesListener>()
                                      .player
                                      .processingState ==
                                  ProcessingState.ready &&
                              episodePlaybackState != null) {
                            if (overlayEntry == null &&
                                episodePlaybackState.values.first.eId !=
                                    ep.eId) {
                              showOverlayPlayerMin(context);
                            } else {
                              if (overlayEntry != null &&
                                  episodePlaybackState.values.first.eId ==
                                      ep.eId) {
                                removeOverlay();
                              }
                            }
                          }
                        },
                        itemCount: episodes.length,
                        itemBuilder: (context, index) {
                          final episodeToDisplay = episodes[index];
                          return Stack(
                            children: [
                              SafeArea(
                                child: CustomScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  slivers: [
                                    FlexibleSpace(
                                      podcast: podcastState.currentPodcast,
                                      episode: episodeToDisplay,
                                      title: episodeToDisplay.title,
                                    ),
                                    SliverPadding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20.0, 20.0, 20.0, 0.0),
                                      sliver: SliverToBoxAdapter(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(formatTimestamp(
                                                episodeToDisplay
                                                    .datePublished)),
                                            Expanded(
                                              child: EpisodeActionsRow(
                                                  episode: episode),
                                            ),
                                            if (episode.isSubscribed)
                                              IconButton(
                                                onPressed: () => showEpisodeActionsDialog(context, episode),
                                                icon: const Icon(
                                                  Icons.more_horiz_rounded,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SliverPadding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20.0, 0.0, 0.0, 20.0),
                                        sliver: SliverToBoxAdapter(
                                          child: Text(
                                            episodeToDisplay.duration! == 0
                                                ? ""
                                                : intToDurationFormatted(
                                                    episodeToDisplay.duration!,
                                                  ),
                                          ),
                                        )),
                                    SliverPadding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20.0, 0.0, 20.0, 170.0),
                                      sliver: SliverToBoxAdapter(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              episodeToDisplay.description,
                                              style: const TextStyle(
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            const SizedBox(height: 16.0),
                                            if (episodeToDisplay.episodeNr !=
                                                0) ...[
                                              Text(
                                                "${episodeToDisplay.episodeNr}${podcastState.currentPodcast.episodeCount != null ? "/${podcastState.currentPodcast.episodeCount}" : ""}",
                                              ),
                                              const SizedBox(height: 16.0),
                                            ],
                                            if (podcastState
                                                        .currentPodcast.link !=
                                                    null &&
                                                podcastState.currentPodcast
                                                    .link!.isNotEmpty &&
                                                podcastState
                                                    .currentPodcast.link!
                                                    .contains('://'))
                                              PodcastWebsiteLink(
                                                  link: podcastState
                                                      .currentPodcast.link!),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: episodePlaybackState != null &&
                                    episodePlaybackState.values.first.eId ==
                                        episodeToDisplay.eId,
                                child: Positioned(
                                  bottom: MediaQuery.of(context).padding.bottom,
                                  left: 0,
                                  right: 0,
                                  child: const PlayerControls(),
                                ),
                              )
                            ],
                          );
                        });
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
          );
        },
      ),
    );
  }
}
