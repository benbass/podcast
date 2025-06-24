import '../entities/episode_entity.dart';
import '../entities/podcast_filter_settings_entity.dart';

abstract class EpisodeRepository {

  Stream<List<EpisodeEntity>> getEpisodesStream({
    required int feedId,
    required bool isSubscribed,
    required PodcastFilterSettingsEntity filterSettings,
  });

  Future<void> fetchRemoteEpisodesByFeedIdAndSaveToDb({
    required int feedId,
    bool? markAsSubscribed,
  });

  Future<void> refreshEpisodesFromServer({
    required int feedId,
  });

  Stream<EpisodeEntity?> getEpisodeStream({required int episodeId});
  Stream<int> unreadLocalEpisodesCount({required int feedId});
}
