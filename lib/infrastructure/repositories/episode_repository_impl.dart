import 'package:podcast/domain/entities/episode_entity.dart';
import '../../domain/repositories/episode_repository.dart';
import '../datasources/episode_datasources.dart';

class EpisodeRepositoryImpl implements EpisodeRepository {
  final EpisodeDataSources episodeDataSources;

  EpisodeRepositoryImpl({required this.episodeDataSources});

  @override
  Stream<List<EpisodeEntity>> fetchEpisodesAsStreamByFeedId(int id) {
    return episodeDataSources.fetchEpisodesAsStreamByFeedId(id);
  }

  @override
  Future<List<EpisodeEntity>> fetchEpisodesByFeedId(int id) {
    return episodeDataSources.fetchEpisodesByFeedId(id);
  }
}
