import '../entities/episode_entity.dart';

abstract class EpisodeRepository {
  Stream<List<EpisodeEntity>> getEpisodes({
    required bool subscribed,
    required int feedId,
    required bool onlyUnread,
  });
  Stream<int> unreadLocalEpisodesCount({required int feedId});
}
