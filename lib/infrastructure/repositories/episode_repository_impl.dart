import 'package:podcast/domain/entities/episode_entity.dart';
import '../../domain/repositories/episode_repository.dart';
import '../datasources/episode_datasources.dart';

class EpisodeRepositoryImpl implements EpisodeRepository {
  final EpisodeLocalDatasource episodeLocalDatasource;

  EpisodeRepositoryImpl({
    required this.episodeLocalDatasource,
  });

  @override
  Stream<List<EpisodeEntity>> getEpisodes({
    required bool subscribed,
    required int feedId,
    required String podcastTitle,
    required String filterStatus,
    required bool refresh,
    String? filterText,
  }) {
    return episodeLocalDatasource.getEpisodes(
      subscribed: subscribed,
      feedId: feedId,
      podcastTitle: podcastTitle,
      filterStatus: filterStatus,
      refresh: refresh,
      filterText: filterText,
    );
  }

  @override
  Stream<EpisodeEntity?> getEpisodeStream({required int episodeId}) {
    return episodeLocalDatasource.getEpisodeStream(episodeId: episodeId);
  }

  @override
  Stream<int> unreadLocalEpisodesCount({required int feedId}) {
    return episodeLocalDatasource.unreadLocalEpisodesCount(feedId: feedId);
  }
}
