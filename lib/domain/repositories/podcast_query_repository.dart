import 'package:podcast/domain/entities/podcast_entity.dart';

abstract class PodcastQueryRepository {
  Future<List<PodcastEntity>> getPodcastsOnQuery(String keyword);
}
