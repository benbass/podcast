import 'package:podcast/domain/entities/episode_entity.dart';
import '../../domain/entities/podcast_filter_settings_entity.dart';
import '../../domain/repositories/episode_repository.dart';
import '../datasources/episode_datasources.dart';

class EpisodeRepositoryImpl implements EpisodeRepository {
  final EpisodeLocalDatasource episodeLocalDatasource;
  final EpisodeRemoteDataSource episodeRemoteDatasource;

  EpisodeRepositoryImpl({
    required this.episodeLocalDatasource,
    required this.episodeRemoteDatasource,
  });

  @override
  Stream<List<EpisodeEntity>> getEpisodesStream({
    required int feedId,
    required bool isSubscribed,
    required PodcastFilterSettingsEntity filterSettings,
  }) {
    return episodeLocalDatasource.getEpisodesStream(
      feedId: feedId,
      isSubscribed: isSubscribed,
      filterSettings: filterSettings,
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

  @override
  Future<void> fetchRemoteEpisodesByFeedIdAndSaveToDb({
    required int feedId,
    bool? markAsSubscribed,
  }) {
    return episodeRemoteDatasource.fetchRemoteEpisodesByFeedIdAndSaveToDb(
      feedId: feedId,
      markAsSubscribed: markAsSubscribed,
    );
  }

  @override
  Future<void> refreshEpisodesFromServer({
    required int feedId,
  }) {
    return episodeRemoteDatasource.refreshEpisodesFromServer(
      feedId: feedId,
    );
  }
}
