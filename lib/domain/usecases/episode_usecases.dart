import 'package:podcast/domain/repositories/episode_repository.dart';

import '../entities/episode_entity.dart';

class EpisodeUseCases {
  final EpisodeRepository episodeRepository;

  EpisodeUseCases({required this.episodeRepository});

  Stream<List<EpisodeEntity>> getEpisodes({
    required bool subscribed,
    required int feedId,
    required bool showRead,
  }) {
    return episodeRepository.getEpisodes(
      subscribed: subscribed,
      feedId: feedId,
      showRead: showRead,
    );
  }

  Stream<int> unreadLocalEpisodesCount({required int feedId}) {
    return episodeRepository.unreadLocalEpisodesCount(feedId: feedId);
  }

  Future<List<EpisodeEntity>> newEpisodesList({required int feedId}) async {
    final List<EpisodeEntity> currentLocalEpisodes = await getEpisodes(
      subscribed: true, // we refresh on subscribed podcasts only
      feedId: feedId,
      showRead: true, // must be true, otherwise we don't get all episodes into the set
    )
        .first;

    List<EpisodeEntity> currentEpisodesOnRemote = await getEpisodes(
      subscribed:
      false, // false because we want to fetch episodes from remote, not from database only
      feedId: feedId,
      showRead: true,
    )
        .first;

    final Set<int> currentEpisodeIds =
    currentLocalEpisodes.map((ep) => ep.eId).toSet();

    final List<EpisodeEntity> newEpisodes = currentEpisodesOnRemote
        .where((episode) => !currentEpisodeIds.contains(episode.eId))
        .toList()
      ..sort((a, b) => a.datePublished.compareTo(b.datePublished));

    return newEpisodes;
  }
}
