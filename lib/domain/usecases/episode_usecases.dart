import 'package:podcast/domain/repositories/episode_repository.dart';

import '../entities/episode_entity.dart';
import '../entities/podcast_entity.dart';

class EpisodeUseCases {
  final EpisodeRepository episodeRepository;

  EpisodeUseCases({required this.episodeRepository});

  Stream<List<EpisodeEntity>> getEpisodes({
    required bool subscribed,
    required int feedId,
    required bool showRead,
  }) {
    return episodeRepository.getEpisodes(
        subscribed: subscribed, feedId: feedId, showRead: showRead);
  }

  Stream<int> unreadLocalEpisodesCount({required int feedId}) {
    return episodeRepository.unreadLocalEpisodesCount(feedId: feedId);
  }

  Stream<List<EpisodeEntity>> refreshEpisodes({
    required PodcastEntity podcast,
  }) {
    return episodeRepository.refreshEpisodes(
      podcast: podcast,
    );
  }
}
