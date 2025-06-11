import '../entities/episode_entity.dart';
import '../entities/podcast_filter_settings_entity.dart';

abstract class EpisodeRepository {

  Stream<List<EpisodeEntity>> getEpisodesStream({
    required int feedId,
    required String podcastTitle,
    required bool isSubscribed,
    required PodcastFilterSettingsEntity filterSettings,
  });

  Future<void> fetchRemoteEpisodesByFeedIdAndSaveToDb({
    required int feedId,
    required String podcastTitle,
    bool? markAsSubscribed,
  });

  Future<void> refreshEpisodesFromServer({
    required int feedId,
    required String podcastTitle,
  });

  Stream<EpisodeEntity?> getEpisodeStream({required int episodeId});
  Stream<int> unreadLocalEpisodesCount({required int feedId});
}
