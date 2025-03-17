import 'package:podcast/domain/repositories/episode_repository.dart';

import '../entities/episode_entity.dart';

class EpisodeUseCases {
  final EpisodeRepository episodeRepository;

  EpisodeUseCases({required this.episodeRepository});

  Stream<List<EpisodeEntity>> getEpisodes({
    required bool subscribed,
    required int feedId,
    required bool onlyUnread,
  }) {
    return episodeRepository.getEpisodes(
        subscribed: subscribed, feedId: feedId, onlyUnread: onlyUnread);
  }

  Stream<int> unreadLocalEpisodesCount({required int feedId}) {
    return episodeRepository.unreadLocalEpisodesCount(feedId: feedId);
  }

}
