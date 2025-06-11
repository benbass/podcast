import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/application/episode_selection_cubit/episode_selection_cubit.dart';
import 'package:podcast/domain/usecases/episode_usecases.dart';
import 'package:podcast/injection.dart';

import 'package:podcast/presentation/custom_widgets/elevated_button_subscribe.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/animated_download_icon.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/conditional_floating_action_buttons.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/episode_card_for_list.dart';
import '../../application/episodes_bloc/episodes_bloc.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../../application/podcast_settings_cubit/podcast_settings_cubit.dart';
import '../../domain/entities/podcast_filter_settings_entity.dart';
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
  @override
  void initState() {
    super.initState();
    final podcastState = context.read<PodcastBloc>().state;
    final currentPodcast = podcastState.currentPodcast;
    context.read<PodcastSettingsCubit>().loadSettings(currentPodcast.id);
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
          return BlocProvider<EpisodesBloc>(
            key: ValueKey(currentPodcast.id),
            create: (blocContext) {
              final settingsCubit =
                  BlocProvider.of<PodcastSettingsCubit>(blocContext);
              return EpisodesBloc(
                episodeUseCases: getIt<EpisodeUseCases>(),
                podcastSettingsCubit: settingsCubit,
              )..add(LoadEpisodes(
                  feedId: currentPodcast.pId,
                  podcastTitle: currentPodcast.title,
                  isSubscribed: currentPodcast.subscribed,
                  initialFilterSettings: initialFilters,
                ));
            },
            child: const EpisodesListPage(),
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
  const EpisodesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final podcastState = context.watch<PodcastBloc>().state;
    final currentPodcast = podcastState.currentPodcast;

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
          children: [
            BlocBuilder<EpisodesBloc, EpisodesState>(
                builder: (context, episodesState) {
              return SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      collapsedHeight: 60,
                      expandedHeight: 170,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 12,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 80.0),
                              child: Text(
                                currentPodcast.title,
                                style: Theme.of(context).textTheme.displayLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Spacer(),
                                ElevatedButtonSubscribe(
                                  podcast: currentPodcast,
                                ),
                                const SizedBox(
                                  width: 30,
                                ),
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
                                const SizedBox(
                                  width: 30,
                                ),
                                const AnimatedDownloadIcon(),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: StreamBuilder<int>(
                                    stream: getIt<EpisodeUseCases>()
                                        .unreadLocalEpisodesCount(
                                            feedId: currentPodcast.pId),
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
                                          padding: const EdgeInsets.all(5.0),
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
                                ),
                              ],
                            ),
                            if (currentPodcast.subscribed)
                              const RowIconButtonsEpisodes(),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    if (episodesState.status == EpisodesStatus.loading &&
                        episodesState.episodes.isEmpty)
                      const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (episodesState.status == EpisodesStatus.failure)
                      SliverFillRemaining(
                        child: Center(
                          child: buildFailureWidget(
                              message: episodesState.errorMessage ??
                                  'Error loading episodes'),
                        ),
                      )
                    else if (episodesState.episodes.isEmpty &&
                        (episodesState.status == EpisodesStatus.success ||
                            episodesState.status == EpisodesStatus.refreshing))
                      const SliverFillRemaining(
                        child: Center(child: Text("No episodes found")),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 80.0),
                        sliver: SliverList.builder(
                          itemCount: episodesState.episodes.length,
                          itemBuilder: (context, index) {
                            final item = episodesState.episodes[index];
                            return EpisodeCardForList(
                              // episodes Liste wird nicht mehr direkt übergeben,
                              // da jede Karte ihren eigenen Zustand (Favorit etc.) verwaltet
                              episodes: episodesState.episodes,
                              episode: item,
                              podcast:
                                  currentPodcast, // weiterhin vom PodcastBloc
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            }),
            const ConditionalFloatingActionButtons(),
          ],
        ),
      ),
    );
  }
}
