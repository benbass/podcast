import 'package:podcast/domain/entities/episode_entity.dart';
import '../../domain/entities/podcast_entity.dart';
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
    required bool onlyUnread,
  }) {
    return episodeLocalDatasource.getEpisodes(
        subscribed: subscribed, feedId: feedId, onlyUnread: onlyUnread);
  }

  @override
  Stream<int> unreadLocalEpisodesCount({required int feedId}) {
    return episodeLocalDatasource.unreadLocalEpisodesCount(feedId: feedId);
  }

  @override
  Stream<List<EpisodeEntity>> refreshEpisodes({
    required PodcastEntity podcast,
  }) {
    return episodeRemoteDataSource.refreshEpisodes(
      podcast: podcast,
    );
  }
}
