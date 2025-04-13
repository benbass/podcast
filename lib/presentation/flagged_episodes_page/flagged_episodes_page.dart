import 'dart:async';

import 'package:flutter/material.dart';
import 'package:podcast/presentation/flagged_episodes_page/widgets/episode_card_for_flagged.dart';

import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/podcast_entity.dart';
import '../../domain/usecases/episode_usecases.dart';
import '../../domain/usecases/podcast_usecases.dart';
import '../../injection.dart';

class FlaggedEpisodesPage extends StatelessWidget {
  final String flag;
  const FlaggedEpisodesPage({super.key, required this.flag});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    double dimension = 120.0;

    Future<PodcastEntity> podcastForEpisode(EpisodeEntity episode) async {
      // Does podcast exist in db? If not, fetch it from remote.
      return episode.podcast.target ?? await getIt<PodcastUseCases>()
          .fetchPodcastByFeedId(episode.feedId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(flag, style: themeData.textTheme.displayLarge!),
      ),
      body: StreamBuilder(
        stream: getIt<EpisodeUseCases>().getFlaggedEpisodes(flag: flag),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text(
                    'An error occurred while fetching the episodes\nPlease try again.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No episodes found in "${flag.toLowerCase()}"'));
          } else {
            final groupedEpisodes = snapshot.data!;
            return buildListView(
                groupedEpisodes, themeData, podcastForEpisode, dimension);
          }
        },
      ),
    );
  }

  ListView buildListView(
    Map<String, List<EpisodeEntity>> groupedEpisodes,
    ThemeData themeData,
    Future<PodcastEntity> Function(EpisodeEntity episode) podcastForEpisode,
    double dimension,
  ) {
    return ListView.builder(
      itemCount: groupedEpisodes.length,
      itemBuilder: (context, index) {
        final podcastTitle = groupedEpisodes.keys.elementAt(index);
        final episodes = groupedEpisodes[podcastTitle]!;
        return Theme(
          // prevents splash effect on expansion tile when color is overridden to transparent
          data: Theme.of(context).copyWith(splashColor: Colors.transparent),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ExpansionTile(
                showTrailingIcon: false,
                title: Text(
                  podcastTitle,
                  style: themeData.textTheme.displayLarge!,
                ),
                initiallyExpanded: index == 0,
                shape: const RoundedRectangleBorder(),
                children: [
                  ...episodes.map((episode) {
                    return FutureBuilder<PodcastEntity>(
                        future: podcastForEpisode(episode),
                        builder: (context, snapshot) {
                          late PodcastEntity podcast;
                          if (snapshot.hasData) {
                            podcast = snapshot.data!;
                          } else {
                            podcast = PodcastEntity.emptyPodcast();
                          }
                          return EpisodeCardForFlagged(episode: episode, podcast: podcast,);
                        });
                  }),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}
