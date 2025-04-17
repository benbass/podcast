import '../entities/episode_entity.dart';

abstract class EpisodeRepository {
  Stream<List<EpisodeEntity>> getEpisodes({
    required bool subscribed,
    required int feedId,
    required String podcastTitle,
    required bool showRead,
    required bool refresh,
  });
  Stream<int> unreadLocalEpisodesCount({required int feedId});
  Stream<Map<String, List<EpisodeEntity>>> getFlaggedEpisodes({required String flag});
}
