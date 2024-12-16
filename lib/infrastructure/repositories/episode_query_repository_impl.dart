import 'package:podcast/domain/entities/episode_entity.dart';
import '../../domain/repositories/episode_query_repository.dart';
import '../datasources/episode_query_datasources.dart';

class EpisodeQueryRepositoryImpl implements EpisodeQueryRepository {
  final EpisodeQueryDataSources episodeQueryDataSources;

  EpisodeQueryRepositoryImpl({required this.episodeQueryDataSources});

  @override
  Future<List<EpisodeEntity>> getEpisodesOnQuery(int id) async {
    List<EpisodeEntity> episodes =
        await episodeQueryDataSources.fetchEpisodesByFeedId(id);
    return episodes;
  }
}
