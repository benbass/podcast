import 'package:podcast/domain/entities/episode_entity.dart';
import '../../domain/repositories/episode_repository.dart';
import '../datasources/episode_datasources.dart';

class EpisodeRepositoryImpl implements EpisodeRepository {
  final EpisodeDataSources episodeDataSources;

  EpisodeRepositoryImpl({required this.episodeDataSources});

  @override
  Future<List<EpisodeEntity>> fetchEpisodesByFeedId(int id) async {
    return await episodeDataSources.fetchEpisodesByFeedId(id);
  }
}
