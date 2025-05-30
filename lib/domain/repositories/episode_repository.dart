import '../entities/episode_entity.dart';

abstract class EpisodeRepository {
  Stream<List<EpisodeEntity>> getEpisodes({
    required bool subscribed,
    required int feedId,
    required String podcastTitle,
    required String filterStatus,
    required bool refresh,
    String? filterText,
  });
  Stream<EpisodeEntity?> getEpisodeStream({required int episodeId});
  Stream<int> unreadLocalEpisodesCount({required int feedId});
}
