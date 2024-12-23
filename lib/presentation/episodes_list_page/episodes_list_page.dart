import 'package:flutter/material.dart';

import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/episode_card.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/repositories/episode_repository.dart';
import '../../injection.dart';
import '../podcast_results_page/widgets/android_bottom_padding.dart';
import 'widgets/row_icon_buttons_episodes.dart';

class PodcastEpisodesPage extends StatelessWidget {
  final PodcastEntity podcast;

  const PodcastEpisodesPage({
    super.key,
    required this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            podcast.title,
          ),
        ),
      ),
      // Yet to be implemented, instead of a FutureBuilder:
      /*
        body: StreamBuilder<List<EpisodeEntity>>(
        stream: sl<EpisodeRepository>().fetchEpisodesByFeedId(widget.podcast.id),
        ...
       */
      body: FutureBuilder<List<EpisodeEntity>>(
        future: sl<EpisodeRepository>().fetchEpisodesByFeedId(podcast.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<EpisodeEntity> episodes = snapshot.data!;
            return SafeArea(
              child: CustomScrollView(
                slivers: [
                  const SliverPadding(
                      sliver: SliverToBoxAdapter(
                        child: RowIconButtonsEpisodes(),
                      ),
                      padding: EdgeInsets.only(
                        bottom: 20.0,
                      )),
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
          } else if (snapshot.hasError) {
            return Text('Fehler: ${snapshot.error}');
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      bottomNavigationBar: const AndroidBottomPadding(),
    );
  }
}
