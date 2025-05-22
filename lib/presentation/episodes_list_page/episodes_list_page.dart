import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/application/episode_selection_cubit/episode_selection_cubit.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/domain/usecases/episode_usecases.dart';
import 'package:podcast/injection.dart';

import 'package:podcast/presentation/custom_widgets/elevated_button_subscribe.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/animated_download_icon.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/conditional_floating_action_buttons.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/episode_card_for_list.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../custom_widgets/failure_widget.dart';
import '../custom_widgets/page_transition.dart';
import '../podcast_details_page/podcast_details_page.dart';
import 'widgets/row_icon_buttons_episodes.dart';

class EpisodesListPage extends StatelessWidget {
  const EpisodesListPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      child: const Scaffold(
        body: Stack(
          children: [
            EpisodeListWidget(),
            ConditionalFloatingActionButtons(),
          ],
        ),
      ),
    );
  }
}

class EpisodeListWidget extends StatelessWidget {
  const EpisodeListWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    PodcastState state = context.watch<PodcastBloc>().state;
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
                    padding: const EdgeInsets.symmetric(horizontal: 80.0),
                    child: Text(
                      state.currentPodcast.title,
                      style: Theme.of(context).textTheme.displayLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButtonSubscribe(
                        navigate: true,
                        podcast: state.currentPodcast,
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
                      const AnimatedDownloadIcon(),
                    ],
                  ),
                  if (state.currentPodcast.subscribed)
                    const RowIconButtonsEpisodes(),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<List<EpisodeEntity>>(
              initialData: const [],
              // The method getEpisodes checks the subscribed flag of
              // the podcast and returns the correct stream
              // (from objectBox database or from the remote server)
              stream: getIt<EpisodeUseCases>().getEpisodes(
                subscribed: state.currentPodcast.subscribed,
                feedId: state.currentPodcast.pId,
                podcastTitle: state.currentPodcast.title,
                filterStatus: state.episodesFilterStatus.name,
                refresh: false,
                filterText: state.filterText,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return SliverFillRemaining(
                      child: Center(
                    child: buildFailureWidget(
                        message: 'Error loading the episodes'),
                  ));
                } else {
                  return SliverPadding(
                    padding: const EdgeInsets.only(bottom: 80.0),
                    sliver: SliverList.builder(
                      itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                      itemBuilder: (context, index) {
                        List<EpisodeEntity> episodes = snapshot.data ?? [];
                        final item = episodes[index];
                        return EpisodeCardForList(
                          episode: item,
                          podcast: state.currentPodcast,
                        );
                      },
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }
}
