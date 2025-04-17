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
    required String podcastTitle,
    required bool showRead,
    required bool refresh,
  }) {
    return episodeRepository.getEpisodes(
      subscribed: subscribed,
      feedId: feedId,
      podcastTitle: podcastTitle,
      showRead: showRead,
      refresh: refresh,
    );
  }

  Stream<int> unreadLocalEpisodesCount({required int feedId}) {
    return episodeRepository.unreadLocalEpisodesCount(feedId: feedId);
  }

  Stream<Map<String, List<EpisodeEntity>>> getFlaggedEpisodes({required String flag}) => episodeRepository.getFlaggedEpisodes(flag: flag);

}
