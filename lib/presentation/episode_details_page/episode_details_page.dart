import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcast/application/podcast_bloc/podcast_bloc.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/presentation/custom_widgets/episode_actions_row.dart';
import 'package:podcast/presentation/episode_details_page/widgets/player_controls.dart';
import 'package:podcast/presentation/episodes_list_page/episodes_list_page.dart';

import '../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../helpers/core/utilities/format_utilities.dart';
import '../custom_widgets/decoration/box_decoration.dart';
import '../custom_widgets/dialogs/episode_actions_dialog.dart';
import '../../helpers/listeners/player_listener.dart';
import '../../injection.dart';
import '../audioplayer_overlays/audioplayer_overlays.dart';
import '../custom_widgets/flexible_space.dart';
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
    final podcastState =
        BlocProvider.of<PodcastBloc>(context, listen: false).state;
    final List<EpisodeEntity> episodes = widget.episodes; //snapshot.data!;

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
      child: BlocBuilder<EpisodePlaybackCubit, EpisodePlaybackState>(
        builder: (context, episodePlaybackState) {
          return Scaffold(
            body: PageView.builder(
                controller: pageController,
                onPageChanged: (index) async {
                  // Handle mini player overlay visibility
                  final episodeOnNewPage = episodes[index];

                  if (episodePlaybackState.episode == null) {
                    return;
                  }

                  if (episodePlaybackState.episode!.eId !=
                      episodeOnNewPage.eId) {
                    if (overlayEntry == null &&
                        getIt<PlayerStatesListener>().player.processingState ==
                            ProcessingState.ready) {
                      showOverlayPlayerMin(context);
                    }
                  } else if (episodePlaybackState.episode!.eId ==
                      episodeOnNewPage.eId) {
                    removeOverlay();
                  }
                },
                itemCount: episodes.length,
                itemBuilder: (context, index) {
                  final episodeToDisplay = episodes[index];
                  // The user may want to play this episode: we already inform the Cubit about podcast and episodes
                  BlocProvider.of<EpisodePlaybackCubit>(context)
                      .setPlaybackEpisode(
                    podcast: podcastState.currentPodcast,
                    playlist: episodes,
                    startIndexInPlaylist: index,
                  );

                  bool shouldShowPlayerControls =
                      episodePlaybackState.episode != null &&
                          episodePlaybackState.episode!.eId ==
                              episodeToDisplay.eId;

                  if (shouldShowPlayerControls) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      removeOverlay();
                    });
                  }
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
                              padding: const EdgeInsets.all(
                                20.0,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: Container(
                                  decoration: buildBoxDecoration(context),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      8.0,
                                    ),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(FormatUtilities
                                                  .formatTimestamp(
                                                      episodeToDisplay
                                                          .datePublished)),
                                              if (episodeToDisplay.isSubscribed)
                                                Expanded(
                                                  child: EpisodeActionsRow(
                                                      episode:
                                                          episodeToDisplay),
                                                ),
                                              const SizedBox(width: 20),
                                              if (episodeToDisplay.isSubscribed)
                                                IconButton(
                                                  onPressed: () =>
                                                      EpisodeActionsDialog
                                                          .showEpisodeActionsDialog(
                                                              context,
                                                              episodeToDisplay),
                                                  icon: const Icon(
                                                    Icons.more_horiz_rounded,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          if (!episodeToDisplay.isSubscribed)
                                            const SizedBox(
                                              height: 20.0,
                                            ),
                                          Text(
                                            episodeToDisplay.duration! == 0
                                                ? ""
                                                : FormatUtilities
                                                    .intToDurationFormatted(
                                                    episodeToDisplay.duration!,
                                                  ),
                                          ),
                                        ]),
                                  ),
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 0.0, 20.0, 170.0),
                              sliver: SliverToBoxAdapter(
                                child: Container(
                                  decoration: buildBoxDecoration(context),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
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
                                        if (podcastState.currentPodcast.link !=
                                                null &&
                                            podcastState.currentPodcast.link!
                                                .isNotEmpty &&
                                            podcastState.currentPodcast.link!
                                                .contains('://'))
                                          Row(
                                            children: [
                                              PodcastWebsiteLink(
                                                  link: podcastState
                                                      .currentPodcast.link!),
                                              const SizedBox(
                                                width: 30,
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  if (getIt<PlayerStatesListener>()
                                                              .player
                                                              .processingState ==
                                                          ProcessingState
                                                              .ready &&
                                                      overlayEntry == null) {
                                                    showOverlayPlayerMin(
                                                        context);
                                                  }
                                                  Navigator.push(
                                                      context,
                                                      ScaleRoute(
                                                        page:
                                                            const PodcastDetailsPage(),
                                                      ));
                                                },
                                                icon: const Icon(
                                                  Icons.info_outline_rounded,
                                                  size: 30,
                                                ),
                                              ),
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
                      ),
                      Visibility(
                        visible: shouldShowPlayerControls,
                        child: Positioned(
                          bottom: MediaQuery.of(context).padding.bottom,
                          left: 0,
                          right: 0,
                          child: PlayerControls(
                            pageController: pageController,
                            podcast: podcastState.currentPodcast,
                          ),
                        ),
                      )
                    ],
                  );
                }),
          );
        },
      ),
    );
  }
}
