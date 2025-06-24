import 'package:podcast/domain/repositories/episode_repository.dart';

import '../entities/episode_entity.dart';
import '../entities/podcast_filter_settings_entity.dart';

class EpisodeUseCases {
  final EpisodeRepository episodeRepository;

  EpisodeUseCases({required this.episodeRepository});

  // LOCAL DATA SOURCE
  // Provides a stream of episodes that reacts to DB changes and filters
  Stream<List<EpisodeEntity>> getEpisodesStream({
    required int feedId,
    required bool isSubscribed,
    required PodcastFilterSettingsEntity filterSettings,
    String? filterText,
  }) {
    return episodeRepository.getEpisodesStream(
      feedId: feedId,
      isSubscribed: isSubscribed,
      filterSettings: filterSettings,
    );
  }

  // Provides a stream of a specific episode that reacts to DB changes and filters
  Stream<EpisodeEntity?> getEpisodeStream({required int episodeId}) {
    return episodeRepository.getEpisodeStream(episodeId: episodeId);
  }

  Stream<int> unreadLocalEpisodesCount({required int feedId}) {
    return episodeRepository.unreadLocalEpisodesCount(feedId: feedId);
  }
  // END LOCAL DATA SOURCE

  // REMOTE DATA SOURCE
  // Is called when podcast is not subscribed (when podcast is result of a search or is a trending podcast).
  // Gets remote episodes and saves them to local DB: they are deleted at app close if podcast is not subscribed.
  Future<void> fetchRemoteEpisodesByFeedIdAndSaveToDb({
    required int feedId,
    bool? markAsSubscribed,
  }){
    return episodeRepository.fetchRemoteEpisodesByFeedIdAndSaveToDb(
      feedId: feedId,
      markAsSubscribed: markAsSubscribed,
    );
  }

  // Fetches new episodes from the server and saves them to the local database.
  Future<void> refreshEpisodesFromServer({
    required int feedId,
  }) {
    return episodeRepository.refreshEpisodesFromServer(
      feedId: feedId,
    );
  }
  // END REMOTE DATA SOURCE

}
