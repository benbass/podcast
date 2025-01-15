import 'package:podcast/domain/entities/podcast_entity.dart';
import '../../domain/repositories/podcast_repository.dart';
import '../datasources/podcast_datasources.dart';

class PodcastRepositoryImpl implements PodcastRepository {
  final PodcastDataSources podcastDataSources;
  const PodcastRepositoryImpl({
    required this.podcastDataSources,
  });

  @override
  Future<List<PodcastEntity>> fetchPodcastsByKeywords(String keyword) async {
    return await podcastDataSources.fetchPodcastsByKeywords(keyword);
  }
}