import 'dart:io';

import '../../core/globals.dart';
import '../../objectbox.g.dart';
import '../../domain/entities/podcast_entity.dart';
import '../../domain/entities/episode_entity.dart';

/// For unsubscribed podcasts, clean device storage (artwork files) and database at app closing
bool deletePodcastsAndArtworkFiles() {
  bool success = true;
  // Get unsubscribed podcasts from db
  final queryBuilderPodcasts =
      podcastBox.query(PodcastEntity_.subscribed.equals(false)).build();
  final resultPodcasts = queryBuilderPodcasts.find();

  // Get unsubscribed episodes with any flag from db
  final queryBuilderEpisodes = episodeBox
      .query(EpisodeEntity_.isSubscribed.equals(false).and(
            EpisodeEntity_.read
                .equals(true)
                .or(EpisodeEntity_.position.greaterThan(0))
                .or(EpisodeEntity_.filePath.notNull())
                .or(EpisodeEntity_.favorite.equals(true)),
          ))
      .build();
  final resultEpisodes = queryBuilderEpisodes.find();

  // Add feedIds from un-flagged episodes to set
  final Set feedIds = {};
  for (EpisodeEntity episode in resultEpisodes) {
    feedIds.add(episode.feedId);
  }

  for (PodcastEntity podcast in resultPodcasts) {
    // Delete artwork file from device storage and podcast from db only if its
    // feed id does not exist in the set of feedIds. We want to keep artwork and podcast
    // when user flagged an episode in some way.
    if (!feedIds.contains(podcast.pId)) {
      if (podcast.artworkFilePath != null) {
        File artworkFile = File(podcast.artworkFilePath!);
        if (artworkFile.existsSync()) {
          try {
            artworkFile.delete();
          } catch (e) {
            success = false;
          }
        }
      }
      podcastBox.remove(podcast.id);
    }
  }

  return success;
}
