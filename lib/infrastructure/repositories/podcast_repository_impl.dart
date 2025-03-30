import 'dart:io';

import 'package:podcast/core/globals.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/infrastructure/datasources/episode_datasources.dart';
import '../../domain/entities/episode_entity.dart';
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
  Future<PodcastEntity> fetchPodcastByFeedId(int feedId) async {
    final PodcastEntity podcast = await podcastDataSources.fetchPodcastByFeedId(feedId);
    return podcast;
  }

  @override
  Future<bool> subscribeToPodcast(PodcastEntity podcast) async {
    try {
      // Save artwork to file.
      final String artworkFilePath =
          await saveArtworkToFile(podcast.artwork) ?? "null";

      // Determine if episodes need to be fetched.
      final podcastWithEpisodes = podcast.episodes.isEmpty
          ? await _fetchEpisodesIfMissing(podcast)
          : podcast;

      // Update the subscribed status of the podcast.
      final subscribedPodcast =
          _markPodcastAsSubscribed(podcastWithEpisodes, artworkFilePath);

      // Persist the updated podcast data.
      podcastBox.put(subscribedPodcast);

      return true;
    } catch (e) {
      //print("Error subscribing to podcast: $e");
      return false;
    }
  }

  /// Fetches episodes for a podcast if they are not already present.
  Future<PodcastEntity> _fetchEpisodesIfMissing(PodcastEntity podcast) async {
    final PodcastEntity podcastWithEpisodes =
        await fillPodcastWithEpisodes(podcast);
    return podcastWithEpisodes;
  }

  /// Marks a podcast as subscribed and updates the episodes with the unread episode count.
  PodcastEntity _markPodcastAsSubscribed(
      PodcastEntity podcast, String? filePath) {
    if (filePath != "null") {
      final PodcastEntity subscribedPodcast = podcast.copyWith(
        subscribed: true,
        artworkFilePath: filePath,
      )..episodes.addAll(podcast.episodes);
      return subscribedPodcast;
    } else {
      final PodcastEntity subscribedPodcast = podcast.copyWith(
        subscribed: true,
      )..episodes.addAll(podcast.episodes);
      return subscribedPodcast;
    }
  }

  @override
  Future<void> unsubscribeFromPodcast(PodcastEntity podcast) async {
    // Delete episodes in db
    for (var episode in podcast.episodes) {
      episodeBox.remove(episode.id);
    }
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

  Future<List<EpisodeEntity>> _fetchEpisodesFromRemote(int feedId, String podcastTitle) {
    final Stream<List<EpisodeEntity>> episodes =
        episodeDataSources.fetchRemoteEpisodesByFeedId(feedId: feedId, podcastTitle: podcastTitle);
    return episodes.first;
  }

  @override
  Future<PodcastEntity> fillPodcastWithEpisodes(PodcastEntity podcast) async {
    final List<EpisodeEntity> episodes =
        await _fetchEpisodesFromRemote(podcast.pId, podcast.title);
    podcast.episodes.addAll(episodes);
    return podcast;
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

        // Remove old object from query result
        //currentQueryResult.removeAt(index);
        // Insert new object in query result
        // the state of the new object (subscribed or not) was already set in the SubscribeToPodcastEvent or UnSubscribeFromPodcastEvent
        //currentQueryResult.insert(index, currentPodcast);

        // Replace
        currentQueryResult[index] = currentPodcast;
      }
    }
    return currentQueryResult;
  }
}
