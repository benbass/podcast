import '../entities/episode_entity.dart';

abstract class EpisodeRepository {
  Stream<List<EpisodeEntity>> fetchEpisodesByFeedId(int id);
}
