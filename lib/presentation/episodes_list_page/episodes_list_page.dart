import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/custom_widgets/elevated_button_subscribe.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/episode_card.dart';
import '../../application/episodes_bloc/episodes_bloc.dart';
import '../../domain/entities/episode_entity.dart';
import 'widgets/row_icon_buttons_episodes.dart';

class EpisodesPage extends StatelessWidget {
  final PodcastEntity podcast;

  const EpisodesPage({
    super.key,
    required this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    final episodesBloc = BlocProvider.of<EpisodesBloc>(context);
    BlocProvider.of<EpisodesBloc>(context)
        .add(EpisodesFetchingEvent(id: podcast.id));
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
      body: BlocBuilder<EpisodesBloc, EpisodesState>(
        builder: (context, state) {
          if (state is EpisodesInitial) {
            episodesBloc.add(EpisodesFetchingEvent(id: podcast.id));
          } else if (state is EpisodesFetchingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is EpisodesReceivedState) {
            // let's test UI with user parameters...
            List<EpisodeEntity> episodes = state.episodes;
            episodes.insert(
                0,
                episodes[0]
                    .copyWith(favorite: true, position: 2000, read: true));
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
                          const ElevatedButtonSubscribe(),
                          const RowIconButtonsEpisodes(),
                          const SizedBox(height: 12,),
                        ],
                      ),
                    ),
                  ),
                  SliverList.builder(
                    itemCount: state.episodes.length,
                    itemBuilder: (context, index) {
                      final item = state.episodes[index];
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
          return const SizedBox();
        },
      ),
    );
  }
}
