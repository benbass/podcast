import '../entities/episode_entity.dart';

abstract class EpisodeRepository {
  Future<List<EpisodeEntity>> fetchEpisodesByFeedId(int id);
}
