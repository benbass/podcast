import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/custom_widgets/elevated_button_subscribe.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/episode_card.dart';
import '../../application/podcasts_bloc/podcasts_bloc.dart';
import '../../domain/entities/episode_entity.dart';
import 'widgets/row_icon_buttons_episodes.dart';

class EpisodesListPage extends StatelessWidget {
  final PodcastEntity podcast;

  const EpisodesListPage({
    super.key,
    required this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    final podcastsBloc = BlocProvider.of<PodcastsBloc>(context);
    if(!podcast.subscribed) {
      podcastsBloc.add(FillPodcastWithEpisodesEvent(podcast: podcast));
    }
    return Scaffold(
      /*  appBar: AppBar(
        toolbarHeight: 80,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            podcast.title,
          ),
        ),
      ),*/
      body: BlocBuilder<PodcastsBloc, PodcastsState>(
        builder: (context, state) {
          if (state is PodcastFillingWithEpisodesState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is PodcastFillWithEpisodesSuccessState) {
            List<EpisodeEntity> episodes = state.podcast.episodes;

            // let's test UI with user parameters...
            /*episodes.insert(
                0,
                episodes[0]
                    .copyWith(favorite: true, position: 2000, read: true));*/

            return buildBodyContent(context, episodes);
          } else if (state is SubscribedPodcastsFetchSuccessState) {
            List<EpisodeEntity> episodes = podcast.episodes;
            return buildBodyContent(context, episodes);
          } else if (state is PodcastChangeSubscriptionState) {
            List<EpisodeEntity> episodes = podcast.episodes;
            return buildBodyContent(context, episodes);
          }
          return const SizedBox();
        },
      ),
    );
  }

  SafeArea buildBodyContent(BuildContext context, List<EpisodeEntity> episodes) {
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
                            podcast.title,
                            style: Theme.of(context).textTheme.displayLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ElevatedButtonSubscribe(podcast: podcast, navigate: true,),
                        const RowIconButtonsEpisodes(),
                        const SizedBox(height: 12,),
                      ],
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: episodes.length,
                  itemBuilder: (context, index) {
                    final item = episodes[index];
                    return EpisodeCard(
                      item: item,
                      podcast: podcast,
                    );
                  },
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 80,
                  ),
                ),
              ],
            ),
          );
  }
}
