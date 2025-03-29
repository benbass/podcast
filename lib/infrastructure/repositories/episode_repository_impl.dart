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
    required String podcastTitle,
    required bool showRead,
  }) {
    return episodeLocalDatasource.getEpisodes(
        subscribed: subscribed, feedId: feedId, podcastTitle: podcastTitle, showRead: showRead);
  }

  @override
  Stream<int> unreadLocalEpisodesCount({required int feedId}) {
    return episodeLocalDatasource.unreadLocalEpisodesCount(feedId: feedId);
  }

  @override
  Future<List<EpisodeEntity>> getNewEpisodesByFeedId({required int feedId, required String podcastTitle}) async {
    return await episodeLocalDatasource.getNewEpisodesByFeedId(feedId: feedId, podcastTitle: podcastTitle);
  }

  @override
  Stream<Map<String, List<EpisodeEntity>>> getFlaggedEpisodes({required String flag}) {
    return episodeLocalDatasource.getFlaggedEpisodes(flag: flag);
  }
}
