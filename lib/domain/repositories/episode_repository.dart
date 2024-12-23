import '../entities/episode_entity.dart';

abstract class EpisodeRepository {
  // Yet to be implemented, instead of a FutureBuilder:
  // Stream<List<EpisodeEntity>> fetchEpisodesByFeedId(int id);
  Future<List<EpisodeEntity>> fetchEpisodesByFeedId(int id);
}
