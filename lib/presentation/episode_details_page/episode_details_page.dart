import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/presentation/custom_widgets/episode_actions_row.dart';
import 'package:podcast/presentation/episode_details_page/widgets/player_controls.dart';
import '../../application/playback/playback_cubit/playback_cubit.dart';
import '../../application/podcast/podcast_bloc/podcast_bloc.dart';
import '../../domain/entities/podcast_entity.dart';
import '../../domain/usecases/episode_usecases.dart';
import '../../helpers/core/utilities/format_utilities.dart';
import '../../helpers/player/audiohandler.dart';
import '../custom_widgets/decoration/box_decoration.dart';
import '../custom_widgets/dialogs/episode_actions_dialog.dart';
import '../../helpers/listeners/player_listener.dart';
import '../../injection.dart';
import '../audioplayer_overlays/audioplayer_overlays.dart';
import '../custom_widgets/effects/backdropfilter.dart';
import '../custom_widgets/effects/opacity_body.dart';
import '../custom_widgets/playback_linear_progress_indicator.dart';
import '../episodes_list_page/widgets/animated_download_icon.dart';
import 'widgets/episode_details_flexible_space.dart';
import '../custom_widgets/page_transition.dart';
import '../podcast_details_page/podcast_details_page.dart';
import 'widgets/podcast_website_link.dart';

class EpisodeDetailsPage extends StatefulWidget {
  final List<EpisodeEntity> episodes;
  final EpisodeEntity initialEpisode;

  const EpisodeDetailsPage({
    super.key,
    required this.episodes,
    required this.initialEpisode,
  });

  @override
  State<EpisodeDetailsPage> createState() => _EpisodeDetailsPageState();
}

class _EpisodeDetailsPageState extends State<EpisodeDetailsPage> {
  late PageController pageController;
  late int initialPageIndex;

  @override
  void initState() {
    super.initState();
    initialPageIndex =
        widget.episodes.indexWhere((ep) => ep.eId == widget.initialEpisode.eId);
    if (initialPageIndex == -1) {
      initialPageIndex = 0;
    }
    pageController = PageController(initialPage: initialPageIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<EpisodeEntity> episodes = widget.episodes;

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
        /*Navigator.of(context).push(
          ScaleRoute(
            page: const EpisodesListPageWrapper(),
          ),
        );*/
      },
      child: BlocBuilder<PlaybackCubit, PlaybackState>(
        builder: (context, episodePlaybackState) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: _buildBackButton(context),
              actions: [
                const AnimatedDownloadIcon(),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: () {
                    if (getIt<PlayerStatesListener>().player.processingState ==
                            ProcessingState.ready &&
                        overlayEntry == null) {
                      showOverlayPlayerMin(context);
                    }
                    Navigator.push(
                        context,
                        ScaleRoute(
                          page: const PodcastDetailsPage(),
                        ));
                  },
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    size: 30,
                  ),
                ),
              ],
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                BlocBuilder<PodcastBloc, PodcastState>(
                  builder: (context, podcastState) {
                    return OpacityBody(
                      state: podcastState,
                    );
                  },
                ),
                const BackdropFilterWidget(
                  sigma: 25.0,
                ),
                PageView.builder(
                    controller: pageController,
                    onPageChanged: (index) async {
                      final episodeOnNewPage = episodes[index];

                      final PodcastState podcastState =
                          context.read<PodcastBloc>().state;
                      if (episodeOnNewPage.feedId !=
                          podcastState.currentPodcast.feedId) {
                        final PodcastEntity podcast =
                            episodeOnNewPage.podcast.target!;
                        context
                            .read<PodcastBloc>()
                            .add(PodcastSelectedEvent(podcast: podcast));
                      }

                      // Handle mini player overlay visibility
                      if (episodePlaybackState.episode == null) {
                        return;
                      }
                      if (episodePlaybackState.episode!.eId !=
                          episodeOnNewPage.eId) {
                        if (overlayEntry == null &&
                            getIt<PlayerStatesListener>()
                                    .player
                                    .processingState ==
                                ProcessingState.ready) {
                          showOverlayPlayerMin(context);
                        }
                      } else if (episodePlaybackState.episode!.eId ==
                          episodeOnNewPage.eId) {
                        removeOverlayPlayerMin();
                      }
                    },
                    itemCount: episodes.length,
                    itemBuilder: (context, index) {
                      final episodeToDisplay = episodes[index];

                      bool shouldShowPlayerControls =
                          episodePlaybackState.episode != null &&
                              episodePlaybackState.episode!.eId ==
                                  episodeToDisplay.eId;

                      if (shouldShowPlayerControls) {
                        removeOverlayPlayerMin();
                      }

                      return BlocBuilder<PodcastBloc, PodcastState>(
                        buildWhen: (prev, curr) =>
                            prev.currentPodcast.feedId !=
                            curr.currentPodcast.feedId,
                        builder: (context, podcastState) {
                          PodcastEntity relevantPodcast =
                              podcastState.currentPodcast;
                          if (relevantPodcast.feedId !=
                              episodeToDisplay.feedId) {
                            final found = podcastState.subscribedPodcasts
                                .firstWhere(
                                    (p) => p.feedId == episodeToDisplay.feedId,
                                    orElse: () => relevantPodcast);
                            relevantPodcast = found;
                          }
                          return Stack(
                            children: [
                              CustomScrollView(
                                physics: const BouncingScrollPhysics(),
                                slivers: [
                                  EpisodeDetailsFlexibleSpace(
                                    podcast: relevantPodcast,
                                    episode: episodeToDisplay,
                                    episodeIndex: index,
                                    playlist: episodes,
                                    title: episodeToDisplay.title,
                                  ),
                                  SliverMainAxisGroup(
                                    slivers: [
                                      SliverPadding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20.0, 0.0, 20.0, 20.0),
                                        sliver: SliverToBoxAdapter(
                                          child: Container(
                                            decoration:
                                                buildBoxDecoration(context),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                16.0,
                                                8.0,
                                                16.0,
                                                16.0,
                                              ),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(FormatUtilities
                                                            .formatTimestamp(
                                                                episodeToDisplay
                                                                    .datePublished)),
                                                        if (episodeToDisplay
                                                            .isSubscribed)
                                                          Expanded(
                                                            child:
                                                                EpisodeActionsRow(
                                                              episode:
                                                                  episodeToDisplay,
                                                            ),
                                                          ),
                                                        if (episodeToDisplay
                                                            .isSubscribed)
                                                          IconButton(
                                                            onPressed: () =>
                                                                EpisodeActionsDialog
                                                                    .showEpisodeActionsDialog(
                                                                        context,
                                                                        episodeToDisplay),
                                                            icon: const Icon(
                                                              Icons
                                                                  .more_horiz_rounded,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    if (!episodeToDisplay
                                                        .isSubscribed)
                                                      const SizedBox(
                                                        height: 20.0,
                                                      ),
                                                    Text(
                                                      episodeToDisplay
                                                                  .duration! ==
                                                              0
                                                          ? ""
                                                          : FormatUtilities
                                                              .intToDurationFormatted(
                                                              episodeToDisplay
                                                                  .duration!,
                                                            ),
                                                    ),
                                                  ]),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SliverPadding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20.0, 0.0, 20.0, 220.0),
                                        sliver: SliverToBoxAdapter(
                                          child: Container(
                                            decoration:
                                                buildBoxDecoration(context),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    episodeToDisplay
                                                        .description,
                                                    style: const TextStyle(
                                                      fontSize: 16.0,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16.0),
                                                  if (episodeToDisplay
                                                          .episodeNr !=
                                                      0) ...[
                                                    Text(
                                                      "${episodeToDisplay.episodeNr}${relevantPodcast.episodeCount != null ? "/${relevantPodcast.episodeCount}" : ""}",
                                                    ),
                                                    const SizedBox(
                                                        height: 16.0),
                                                  ],
                                                  if (relevantPodcast.link !=
                                                          null &&
                                                      relevantPodcast
                                                          .link!.isNotEmpty &&
                                                      relevantPodcast.link!
                                                          .contains('://'))
                                                    Row(
                                                      children: [
                                                        PodcastWebsiteLink(
                                                            link:
                                                                relevantPodcast
                                                                    .link!),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              BlocBuilder<PlaybackCubit, PlaybackState>(
                                buildWhen: (previous, current) {
                                  return previous.episode?.eId !=
                                      current.episode?.eId;
                                },
                                builder:
                                    (context, currentlyPlayingEpisodeState) {
                                  return Positioned(
                                    top: 0,
                                    left: 0,
                                    child: StreamBuilder<EpisodeEntity?>(
                                        stream: getIt<EpisodeUseCases>()
                                            .getEpisodeStream(
                                                episodeId: episodeToDisplay.id),
                                        initialData: episodeToDisplay,
                                        builder: (context, snapshot) {
                                          final episodeInProgress =
                                              snapshot.data ?? episodeToDisplay;
                                          return PlaybackLinearProgressIndicator(
                                            themeData: Theme.of(context),
                                            episode: episodeInProgress,
                                            currentlyPlayingEpisode:
                                                currentlyPlayingEpisodeState
                                                    .episode,
                                            paddingHoriz: 0.0,
                                            paddingVert: 0.0,
                                          );
                                        }),
                                  );
                                },
                              ),
                              Visibility(
                                visible: shouldShowPlayerControls,
                                child: Positioned(
                                  bottom: MediaQuery.of(context).padding.bottom,
                                  left: 0,
                                  right: 0,
                                  child: PlayerControls(
                                    pageController: pageController,
                                    podcast: relevantPodcast,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(
            flex: 3,
          ),
          IconButton(
            onPressed: () {
              final audioHandler = getIt<MyAudioHandler>();
              if (audioHandler.player.processingState ==
                      ProcessingState.ready &&
                  overlayEntry == null) {
                showOverlayPlayerMin(context);
              }

              Navigator.of(context).pop();

              /*Navigator.of(context).pushAndRemoveUntil(
                ScaleRoute(
                  page: const EpisodesListPageWrapper(),
                ),
                ModalRoute.withName('/'),
              );*/
            },
            icon: const BackButtonIcon(),
          ),
          const Spacer(flex: 5),
        ],
      ),
    );
  }
}
