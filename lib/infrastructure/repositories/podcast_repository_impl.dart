import 'dart:io';

import 'package:podcast/core/globals.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/infrastructure/datasources/episode_datasources.dart';
import '../../domain/entities/persistent_podcast_settings_entity.dart';
import '../../domain/repositories/podcast_repository.dart';

import '../../helpers/core/utilities/artwork_to_file.dart';
import '../datasources/podcast_datasources.dart';

class PodcastRepositoryImpl implements PodcastRepository {
  final PodcastDataSource podcastDataSources;
  final EpisodeRemoteDataSource episodeDataSources;
  const PodcastRepositoryImpl({
    required this.podcastDataSources,
    required this.episodeDataSources,
  });

  @override
  Future<List<PodcastEntity>> fetchPodcastsByKeywords(String keyword) async {
    return await podcastDataSources.fetchPodcastsByKeyword(keyword);
  }

  @override
  Future<List<PodcastEntity>> fetchTrendingPodcasts() async {
    return await podcastDataSources.fetchTrendingPodcasts();
  }

  @override
  Future<PodcastEntity> fetchPodcastByFeedId(int feedId) async {
    final PodcastEntity podcast =
        await podcastDataSources.fetchPodcastByFeedId(feedId);
    return podcast;
  }

  /// Cache podcast with settings, and artwork to file for unsubscribed podcasts
  @override
  Future<PodcastEntity> savedPodcastWithArtwork(PodcastEntity podcast) async {
    // Check if podcast is already in db, if so return it
    final savedPodcasts = podcastBox.getAll();
    for (var savedPodcast in savedPodcasts) {
      if (savedPodcast.feedId == podcast.feedId) {
        return savedPodcast;
      }
    }

    int id = 0;
    try {
      // Save artwork to file.
      final String artworkFilePath =
          await ArtworkToFile.saveArtworkToFile(podcast.artwork) ?? "null";
      if (artworkFilePath != "null") {
        // Update the artwork and subscribed status of the podcast.
        final PodcastEntity podcastWithArtwork = podcast.copyWith(
          artworkFilePath: artworkFilePath,
          subscribed: false,
        );
        // Persist the updated podcast data.
        id = podcastBox.put(podcastWithArtwork);
      } else {
        id = podcastBox.put(podcast);
      }

      podcastBox.put(podcast);

      return podcastBox.get(id)!;
    } catch (e) {
      print("Error caching artwork and podcast: $e");
    }
    return podcast;
  }

  @override
  Future<bool> subscribeToPodcast(PodcastEntity podcast) async {
    try {
      // Update the subscribed status of the podcast.
      final unsubscribedPodcast = podcastBox.get(podcast.id)!;

      final subscribedPodcast = unsubscribedPodcast.copyWith(subscribed: true);

      PersistentPodcastSettingsEntity? persistentSettings =
          subscribedPodcast.persistentSettings.target;
      if (persistentSettings == null) {
        persistentSettings =
            PersistentPodcastSettingsEntity.defaultPersistentSettings(
                subscribedPodcast.id);
        settingsBox.put(persistentSettings);
        subscribedPodcast.persistentSettings.target = persistentSettings;
      }

      // Persist the updated podcast data.
      podcastBox.put(subscribedPodcast);

      return true;
    } catch (e) {
      //print("Error subscribing to podcast: $e");
      return false;
    }
  }

  @override
  Future<void> unsubscribeFromPodcast(PodcastEntity podcast) async {
    // Delete artwork file in app directory
    if (podcast.artworkFilePath != null) {
      final file = File(podcast.artworkFilePath!);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (e) {
          print("Error deleting file: $e");
        }
      }
    }
    // Delete settings in db
    if (podcast.persistentSettings.target != null) {
      settingsBox.remove(podcast.persistentSettings.target!.id);
    }
    // Delete podcast in db
    podcastBox.remove(podcast.id);
  }

  @override
  Future<List<PodcastEntity>> getSubscribedPodcasts() async {
    return await podcastDataSources.getSubscribedPodcasts() ?? [];
  }

  @override
  Future<List<PodcastEntity>> updatedQueryResult(
      queryResult, currentPodcast) async {
    List<PodcastEntity> currentQueryResult = queryResult;
    if (currentQueryResult.isNotEmpty) {
      // Create a map to store the API podcastIndex ids (feedId) as keys
      Map<int, int> map = {};
      for (PodcastEntity podcast in currentQueryResult) {
        map[podcast.feedId] = 0;
      }
      // Check if object is in map
      if (map.containsKey(currentPodcast.feedId)) {
        // find index of object in query result
        final int index = currentQueryResult
            .indexWhere((element) => element.feedId == currentPodcast.feedId);

        // Replace object in query result with passed object where subscribed is updated
        currentQueryResult[index] = currentPodcast;
      }
    }
    return currentQueryResult;
  }
}
