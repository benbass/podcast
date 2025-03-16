import '../entities/episode_entity.dart';

abstract class EpisodeRepository {
  Stream<List<EpisodeEntity>> fetchEpisodesAsStreamByFeedId(int feedId);
}
