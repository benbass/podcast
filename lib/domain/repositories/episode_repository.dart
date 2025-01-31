import '../entities/episode_entity.dart';

abstract class EpisodeRepository {
  Stream<List<EpisodeEntity>> fetchEpisodesAsStreamByFeedId(int id);
  Future<List<EpisodeEntity>> fetchEpisodesByFeedId(int id);
}
