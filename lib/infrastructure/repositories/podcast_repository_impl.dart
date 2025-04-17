import 'dart:io';

import 'package:podcast/core/globals.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/infrastructure/datasources/episode_datasources.dart';
import '../../domain/repositories/podcast_repository.dart';

import '../../helpers/core/save_artwork_to_file.dart';
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

  @override
  Future<bool> subscribeToPodcast(PodcastEntity podcast) async {
    try {
      // Save artwork to file.
      final String artworkFilePath =
          await saveArtworkToFile(podcast.artwork) ?? "null";

      // Update the subscribed status of the podcast.
      final subscribedPodcast =
          _markPodcastAsSubscribed(podcast, artworkFilePath);

      // Persist the updated podcast data.
      podcastBox.put(subscribedPodcast);

      return true;
    } catch (e) {
      //print("Error subscribing to podcast: $e");
      return false;
    }
  }

  /// returns a podcast with the subscribed flag = true.
  PodcastEntity _markPodcastAsSubscribed(
      PodcastEntity podcast, String? filePath) {
    if (filePath != "null") {
      final PodcastEntity subscribedPodcast = podcast.copyWith(
        subscribed: true,
        artworkFilePath: filePath,
      );
      return subscribedPodcast;
    } else {
      final PodcastEntity subscribedPodcast = podcast.copyWith(
        subscribed: true,
      );
      return subscribedPodcast;
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
      // Create a map to store the API podcastIndex ids (pId) as keys
      Map<int, int> map = {};
      for (PodcastEntity podcast in currentQueryResult) {
        map[podcast.pId] = 0;
      }
      // Check if object is in map
      if (map.containsKey(currentPodcast.pId)) {
        // find index of object in query result
        final int index = currentQueryResult
            .indexWhere((element) => element.pId == currentPodcast.pId);

        // Replace object in query result with passed object where subscribed is updated
        currentQueryResult[index] = currentPodcast;
      }
    }
    return currentQueryResult;
  }
}
