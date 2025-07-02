import 'dart:io';

import '../../core/globals.dart';
import '../../objectbox.g.dart';
import '../../domain/entities/podcast_entity.dart';

/// For unsubscribed podcasts, clean device storage (artwork files) and database at app closing
class UnsubscribedPodcastCleanup {
  static final UnsubscribedPodcastCleanup _instance =
      UnsubscribedPodcastCleanup._internal();
  factory UnsubscribedPodcastCleanup() => _instance;
  UnsubscribedPodcastCleanup._internal();

  /*
  static bool deletePodcastsAndArtworkFiles() {
    // Build a query for episodes that are unsubscribed AND have any flag
    final flaggedEpisodesQuery = episodeBox
        .query(EpisodeEntity_.isSubscribed.equals(false).and(
      EpisodeEntity_.read
          .equals(true)
          .or(EpisodeEntity_.position.greaterThan(0))
          .or(EpisodeEntity_.filePath.notNull())
          .or(EpisodeEntity_.favorite.equals(true)),
    ))
        .build();
    // Get the feedIds of these flagged episodes
    final flaggedFeedIds = flaggedEpisodesQuery.findIds();

    // Build a query for unsubscribed podcasts whose feedId is NOT in the list of flaggedFeedIds
    final podcastsToDeleteQuery = podcastBox
        .query(PodcastEntity_.subscribed.equals(false).and(
      PodcastEntity_.feedId.notOneOf(flaggedFeedIds),
    ))
        .build();

    final podcastsToDelete = podcastsToDeleteQuery.find();

    // Now iterate and delete only the identified podcasts and their artwork
    // Keep artwork and podcast if any of its episodes have a flag (read, position, file, favorite)
    bool success = true;
    for (PodcastEntity podcast in podcastsToDelete) {
      if (podcast.artworkFilePath != null) {
        File artworkFile = File(podcast.artworkFilePath!);
        if (artworkFile.existsSync()) {
          try {
            artworkFile.deleteSync();
          } catch (e) {
            success = false;
            // Consider logging the error here
          }
        }
      }
      podcastBox.remove(podcast.id);
    }
    return success;
  }
  */

  static bool deletePodcastsWithArtworkFilesAndSettings() {
    // Build a query for unsubscribed podcasts
    final podcastsToDeleteQuery =
        podcastBox.query(PodcastEntity_.subscribed.equals(false)).build();

    final podcastsToDelete = podcastsToDeleteQuery.find();

    // Now iterate and delete only the identified podcasts and their artwork
    bool success = true;
    for (PodcastEntity podcast in podcastsToDelete) {
      if (podcast.artworkFilePath != null) {
        File artworkFile = File(podcast.artworkFilePath!);
        if (artworkFile.existsSync()) {
          try {
            artworkFile.deleteSync();
          } catch (e) {
            success = false;
            // Consider logging the error here
          }
        }
      }
      if (podcast.persistentSettings.target != null) {
        settingsBox.remove(podcast.persistentSettings.target!.id);
      }
      podcastBox.remove(podcast.id);
    }
    return success;
  }
}
