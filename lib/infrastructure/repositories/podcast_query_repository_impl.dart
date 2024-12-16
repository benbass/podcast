import 'package:podcast/domain/entities/podcast_entity.dart';
import '../../domain/repositories/podcast_query_repository.dart';
import '../datasources/podcast_query_datasources.dart';

class PodcastQueryRepositoryImpl implements PodcastQueryRepository {
  final PodcastQueryDataSources podcastQueryDataSources;

  PodcastQueryRepositoryImpl({required this.podcastQueryDataSources});

  @override
  Future<List<PodcastEntity>> getPodcastsOnQuery(String keyword) async {
    final List<PodcastEntity> searchResults =
        await podcastQueryDataSources.fetchPodcastsByKeywords(keyword);

    return searchResults;
  }
}
