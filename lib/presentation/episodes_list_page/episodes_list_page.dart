import 'package:flutter/material.dart';

import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/domain/usecases/episode_usecases.dart';
import 'package:podcast/presentation/custom_widgets/elevated_button_subscribe.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/episode_card.dart';
import '../../domain/entities/episode_entity.dart';
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
        body: StreamBuilder<List<EpisodeEntity>>(
        stream: sl<EpisodeUseCases>().fetchEpisodes(podcast.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<EpisodeEntity> episodes = snapshot.data!;

            // we create an entity with fake values for UI tests
            EpisodeEntity epTest =
            episodes.first.copyWith(favorite: true, read: true, position: 2000);
            episodes.insert(0, epTest);

            return SafeArea(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: ElevatedButtonSubscribe(),
                  ),
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
