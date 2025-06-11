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
    required String podcastTitle,
    required bool isSubscribed,
    required PodcastFilterSettingsEntity filterSettings,
  }) {
    return episodeLocalDatasource.getEpisodesStream(
      feedId: feedId,
      podcastTitle: podcastTitle,
      isSubscribed: isSubscribed,
      filterSettings: filterSettings,
    );
  }

  @override
  Future<void> fetchRemoteEpisodesByFeedIdAndSaveToDb({
    required int feedId,
    required String podcastTitle,
    bool? markAsSubscribed,
  }) {
    return episodeRemoteDatasource.fetchRemoteEpisodesByFeedIdAndSaveToDb(
      feedId: feedId,
      podcastTitle: podcastTitle,
      markAsSubscribed: markAsSubscribed,
    );
  }

  @override
  Future<void> refreshEpisodesFromServer({
    required int feedId,
    required String podcastTitle,
  }) {
    return episodeLocalDatasource.refreshEpisodesFromServer(
      feedId: feedId,
      podcastTitle: podcastTitle,
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
