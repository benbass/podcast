import 'package:podcast/core/globals.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/infrastructure/datasources/episode_datasources.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/repositories/podcast_repository.dart';
import '../datasources/podcast_datasources.dart';

class PodcastRepositoryImpl implements PodcastRepository {
  final PodcastDataSource podcastDataSources;
  final EpisodeDataSources episodeDataSources;
  const PodcastRepositoryImpl({
    required this.podcastDataSources,
    required this.episodeDataSources,
  });

  @override
  Future<List<PodcastEntity>> fetchPodcastsByKeywords(String keyword) async {
    return await podcastDataSources.fetchPodcastsByKeyword(keyword);
  }

  @override
  Future<bool> subscribeToPodcast(PodcastEntity podcast) async {
    try {
      // Determine if episodes need to be fetched.
      final podcastWithEpisodes = podcast.episodes.isEmpty
          ? await _fetchEpisodesIfMissing(podcast)
          : podcast;

      // Update the podcast.
      final subscribedPodcast = _markPodcastAsSubscribed(podcastWithEpisodes);

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
  PodcastEntity _markPodcastAsSubscribed(PodcastEntity podcast) {
    final PodcastEntity subscribedPodcast = podcast.copyWith(
      subscribed: true,
      unreadEpisodes: podcast.episodes.length,
    )..episodes.addAll(podcast.episodes);
    return subscribedPodcast;
  }

  @override
  Future<void> unsubscribeFromPodcast(PodcastEntity podcast) async {
    podcastBox.remove(podcast.id);
  }

  @override
  Future<List<PodcastEntity>> getSubscribedPodcasts() async {
    return await podcastDataSources.getSubscribedPodcasts() ?? [];
  }

  @override
  Future<PodcastEntity> fillPodcastWithEpisodes(PodcastEntity podcast) async {
    //final Stream<List<EpisodeEntity>> episodes = episodeDataSources.fetchEpisodesAsStreamByFeedId(podcast.pId);
    //final List<EpisodeEntity> episodesList = await episodes.first;
    final List<EpisodeEntity> episodesFuture =
        await episodeDataSources.fetchEpisodesByFeedId(podcast.pId);
    for (EpisodeEntity episode in episodesFuture) {
      podcast.episodes.add(episode);
    }
    return podcast;
  }

  @override
  Future<PodcastEntity> refreshPodcastEpisodes(PodcastEntity podcast) async {
    // Set current values
    final List<EpisodeEntity> currentEpisodes = podcast.episodes;
    final Set<int> ids = currentEpisodes.map((e) => e.eId).toSet();
    // Fetch episodes
    final List<EpisodeEntity> episodes =
        await episodeDataSources.fetchEpisodesByFeedId(podcast.pId);
    // Filter new episodes based on PodcastIndex episode id
    final List<EpisodeEntity> newEpisodes = episodes
        .where((episode) => !ids.contains(episode.eId))
        .toList()
      ..sort((a, b) => a.datePublished.compareTo(b.datePublished));
    //newEpisodes.insert(0, fakeEpisode);
    podcast.episodes.insertAll(0, newEpisodes);
    if (podcast.subscribed) {
      podcast.episodes
          .applyToDb(); // applyToDb() updates relation only which is more efficient than box.put(object)
    }
    return podcast;
  }
}
