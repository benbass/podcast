import '../entities/episode_entity.dart';

abstract class EpisodeRepository {
  Stream<List<EpisodeEntity>> getEpisodes({
    required bool subscribed,
    required int feedId,
    required bool showRead,
  });
  Future<List<EpisodeEntity>> getNewEpisodesByFeedId({required int feedId});
  Stream<int> unreadLocalEpisodesCount({required int feedId});
}
