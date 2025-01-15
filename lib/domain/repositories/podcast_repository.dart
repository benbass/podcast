import 'package:podcast/domain/entities/podcast_entity.dart';

abstract class PodcastRepository {
  Future<List<PodcastEntity>> fetchPodcastsByKeywords(String keyword);
}