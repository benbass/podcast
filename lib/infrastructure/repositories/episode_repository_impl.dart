import 'package:podcast/domain/entities/episode_entity.dart';
import '../../domain/repositories/episode_repository.dart';
import '../datasources/episode_datasources.dart';

class EpisodeRepositoryImpl implements EpisodeRepository {
  final EpisodeLocalDatasource episodeLocalDatasource;
  final EpisodeRemoteDataSource episodeRemoteDataSource;

  EpisodeRepositoryImpl({
    required this.episodeLocalDatasource,
    required this.episodeRemoteDataSource,
  });

  @override
  Stream<List<EpisodeEntity>> getEpisodes({
    required bool subscribed,
    required int feedId,
    required bool showRead,
  }) {
    return episodeLocalDatasource.getEpisodes(
        subscribed: subscribed, feedId: feedId, showRead: showRead);
  }

  @override
  Stream<int> unreadLocalEpisodesCount({required int feedId}) {
    return episodeLocalDatasource.unreadLocalEpisodesCount(feedId: feedId);
  }

  @override
  Future<List<EpisodeEntity>> getNewEpisodesByFeedId({required int feedId}) async {
    return await episodeLocalDatasource.getNewEpisodesByFeedId(feedId: feedId);
  }
}
