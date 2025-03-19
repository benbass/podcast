import '../entities/episode_entity.dart';
import '../entities/podcast_entity.dart';

abstract class EpisodeRepository {
  Stream<List<EpisodeEntity>> getEpisodes({
    required bool subscribed,
    required int feedId,
    required bool showRead,
  });
  Stream<int> unreadLocalEpisodesCount({required int feedId});
  Stream<List<EpisodeEntity>> refreshEpisodes({
    required PodcastEntity podcast,
  });
}
