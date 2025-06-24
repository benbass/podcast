import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/application/episode_selection_cubit/episode_selection_cubit.dart';
import 'package:podcast/domain/usecases/episode_usecases.dart';
import 'package:podcast/injection.dart';

import 'package:podcast/presentation/episodes_list_page/widgets/animated_download_icon.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/conditional_floating_action_buttons.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/dropdown_filter_menu.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/episode_card.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/toggle_read_visibility.dart';
import '../../application/episodes_bloc/episodes_bloc.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../../application/podcast_settings_cubit/podcast_settings_cubit.dart';
import '../../domain/entities/podcast_filter_settings_entity.dart';
import '../custom_widgets/effects/backdropfilter.dart';
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
        .unreadLocalEpisodesCount(feedId: currentPodcast.pId)
        .asBroadcastStream(); // asBroadcastStream() so stream will be correctly canceled when podcast is being unsubscribed
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
        appBar: AppBar(
          title: StreamBuilder<int>(
            stream: unreadEpisodesStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const SizedBox();
              }
              if (snapshot.hasData) {
                final unreadEpisodesCount = snapshot.data;
                return Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    unreadEpisodesCount.toString(),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.primaryContainer,
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
          actions: [
            const SizedBox(width: 20),
            if (podcastState.currentPodcast.subscribed)
              const RowIconButtonsEpisodes(),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (podcastState.currentPodcast.artworkFilePath != null)
              OpacityBody(
                state: podcastState,
              ),
            const BackdropFilterWidget(
              sigma: 25.0,
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
                            'Error loading episodes for\n${currentPodcast.title}'),
                  );
                } else {
                  return SafeArea(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverAppBar(
                          primary: false,
                          automaticallyImplyLeading: false,
                          backgroundColor: Colors.transparent,
                          pinned: false,
                          flexibleSpace: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (podcastState.currentPodcast.subscribed) ...[
                                  const DropdownFilterMenu(),
                                  const Spacer(),
                                  const AnimatedDownloadIcon(),
                                  const SizedBox(width: 30),
                                  const ToggleReadVisibility(),
                                ],
                                const SizedBox(width: 30),
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
                              ],
                            ),
                          ),
                        ),
                        if (episodesState.episodes.isEmpty &&
                            (episodesState.status == EpisodesStatus.success ||
                                episodesState.status ==
                                    EpisodesStatus.refreshing))
                          SliverFillRemaining(
                            child: Center(
                              child: Text(
                                "No episodes found for\n${currentPodcast.title}",
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        SliverPadding(
                          padding: const EdgeInsets.only(
                            bottom: 80.0,
                          ),
                          sliver: SliverList.builder(
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
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            const ConditionalFloatingActionButtons(),
          ],
        ),
      ),
    );
  }
}
