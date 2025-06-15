import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/application/episode_selection_cubit/episode_selection_cubit.dart';
import 'package:podcast/domain/usecases/episode_usecases.dart';
import 'package:podcast/injection.dart';

import 'package:podcast/presentation/custom_widgets/elevated_button_subscribe.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/animated_download_icon.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/conditional_floating_action_buttons.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/episode_card.dart';
import '../../application/episodes_bloc/episodes_bloc.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../../application/podcast_settings_cubit/podcast_settings_cubit.dart';
import '../../domain/entities/podcast_filter_settings_entity.dart';
import '../custom_widgets/decoration/box_decoration.dart';
import '../custom_widgets/effects/backdropfilter_body.dart';
import '../custom_widgets/effects/opacity_body.dart';
import '../custom_widgets/failure_widget.dart';
import '../custom_widgets/page_transition.dart';
import '../podcast_details_page/podcast_details_page.dart';
import 'widgets/row_icon_buttons_episodes.dart';

class EpisodesListPageWrapper extends StatefulWidget {
  const EpisodesListPageWrapper({super.key});

  @override
  State<EpisodesListPageWrapper> createState() =>
      _EpisodesListPageWrapperState();
}

class _EpisodesListPageWrapperState extends State<EpisodesListPageWrapper> {
  late Stream<int> _unreadEpisodesStream;

  @override
  void initState() {
    super.initState();
    final podcastState = context.read<PodcastBloc>().state;
    final currentPodcast = podcastState.currentPodcast;
    context.read<PodcastSettingsCubit>().loadSettings(currentPodcast.id);
    _unreadEpisodesStream = getIt<EpisodeUseCases>()
        .unreadLocalEpisodesCount(feedId: currentPodcast.pId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final podcastState = context.watch<PodcastBloc>().state;
    final currentPodcast = podcastState.currentPodcast;

    return BlocBuilder<PodcastSettingsCubit, PodcastSettingsState>(
      buildWhen: (previous, current) {
        if (current is PodcastSettingsLoaded &&
            current.podcast.id == currentPodcast.id) {
          return true;
        }
        if (previous is PodcastSettingsLoaded &&
            current is! PodcastSettingsLoaded) {
          return true;
        }
        return false;
      },
      builder: (context, settingsState) {
        if (settingsState is PodcastSettingsLoaded &&
            settingsState.podcast.id == currentPodcast.id) {
          final PodcastFilterSettingsEntity initialFilters =
              settingsState.settings;

          BlocProvider.of<EpisodesBloc>(context).add(LoadEpisodes(
            feedId: currentPodcast.pId,
            podcastTitle: currentPodcast.title,
            isSubscribed: currentPodcast.subscribed,
            initialFilterSettings: initialFilters,
          ));
          return EpisodesListPage(
            unreadEpisodesStream: _unreadEpisodesStream,
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class EpisodesListPage extends StatelessWidget {
  final Stream<int> unreadEpisodesStream;

  const EpisodesListPage({
    super.key,
    required this.unreadEpisodesStream,
  });

  @override
  Widget build(BuildContext context) {
    final podcastState = context.watch<PodcastBloc>().state;
    final currentPodcast = podcastState.currentPodcast;
    ScrollController scrollController = ScrollController();
    const double paddingChangeThreshold = 10;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          if (BlocProvider.of<EpisodeSelectionCubit>(context)
              .state
              .isSelectionModeActive) {
            BlocProvider.of<EpisodeSelectionCubit>(context)
                .toggleSelectionMode();
          }
          return;
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (podcastState.currentPodcast.artworkFilePath != null)
              OpacityBody(
                state: podcastState,
                assetImage: null,
              ),
            const BackdropFilterBody(),
            // Title
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    currentPodcast.title,
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            // Row icon buttons
            Positioned(
              top: 94,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                  animation: scrollController,
                  builder: (context, child) {
                    const double minPadding = 12;
                    const double maxPadding = 65;
                    double calculatePadding = 12;
                    if (scrollController.hasClients &&
                        scrollController.offset > 0) {
                      calculatePadding =
                          (scrollController.offset / paddingChangeThreshold);
                    }
                    final double padding =
                        calculatePadding.clamp(minPadding, maxPadding);
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          Container(
                            decoration: buildBoxDecoration(context),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const BackButton(),
                                  const Spacer(),
                                  ElevatedButtonSubscribe(
                                    podcast: currentPodcast,
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => Navigator.push(
                                        context,
                                        ScaleRoute(
                                          page: const PodcastDetailsPage(),
                                        )),
                                    icon: const Icon(
                                      Icons.info_outline_rounded,
                                      size: 30,
                                    ),
                                  ),
                                  const Spacer(
                                  ),
                                  const AnimatedDownloadIcon(),
                                  const Spacer(),
                                  StreamBuilder<int>(
                                    stream: unreadEpisodesStream,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        final unreadEpisodesCount =
                                            snapshot.data;
                                        return Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(
                                            unreadEpisodesCount.toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primaryContainer,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      } else {
                                        return const SizedBox();
                                      }
                                    },
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ),
                          if (currentPodcast.subscribed)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  decoration: buildBoxDecoration(context),
                                  child: const RowIconButtonsEpisodes()),
                            ),
                        ],
                      ),
                    );
                  }),
            ),
            BlocBuilder<EpisodesBloc, EpisodesState>(
                builder: (context, episodesState) {
              if (episodesState.status == EpisodesStatus.loading &&
                  episodesState.episodes.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              } else if (episodesState.status == EpisodesStatus.failure) {
                return Center(
                  child: buildFailureWidget(
                      message: episodesState.errorMessage ??
                          'Error loading episodes'),
                );
              } else if (episodesState.episodes.isEmpty &&
                  (episodesState.status == EpisodesStatus.success ||
                      episodesState.status == EpisodesStatus.refreshing)) {
                return const Center(child: Text("No episodes found"));
              } else {
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: 80.0, top: currentPodcast.subscribed ? 230 : 170),
                  child: ListView.builder(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: episodesState.episodes.length,
                    itemBuilder: (context, index) {
                      final item = episodesState.episodes[index];
                      return EpisodeCard(
                        episodes: episodesState.episodes,
                        episode: item,
                        podcast: currentPodcast,
                      );
                    },
                  ),
                );
              }
            }),
            const ConditionalFloatingActionButtons(),
          ],
        ),
      ),
    );
  }
}
