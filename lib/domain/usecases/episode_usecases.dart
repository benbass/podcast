import 'package:podcast/domain/repositories/episode_repository.dart';

import '../entities/episode_entity.dart';

class EpisodeUseCases {
  final EpisodeRepository episodeRepository;

  EpisodeUseCases({required this.episodeRepository});

  // Depending on parameters, we either return local or remote data,
  // and for local data we may filter episodes based on read status
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

  Future<List<EpisodeEntity>> getNewEpisodesByFeedId({required int feedId}) {
    return episodeRepository.getNewEpisodesByFeedId(feedId: feedId);
  }
}
