import 'package:podcast/domain/entities/podcast_entity.dart';

import '../entities/episode_entity.dart';

abstract class EpisodeQueryRepository {
  Future<List<EpisodeEntity>> getEpisodesOnQuery(int id);
}
