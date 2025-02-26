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
  Future<dynamic> subscribeToPodcast(PodcastEntity podcast) async {
    try {
      /// 1. Get the episodes for this podcast
      final PodcastEntity podcastWithEpisodes = await fillPodcastWithEpisodes(podcast);
      /// 2. Create podcast with subscribed flag == true AND list of episodes
      // Note that we don't copyWith episodes: ObjectBox requires list to be filled with add or addAll method
      final PodcastEntity podcastWithEpisodesSubscribed = podcastWithEpisodes
          .copyWith(
              subscribed: true,
              unreadEpisodes: podcastWithEpisodes.episodes.length)
        ..episodes.addAll(podcastWithEpisodes.episodes);
      /// 3. Save to db
      podcastBox.put(podcastWithEpisodesSubscribed);
      /// 4. Success. Return obj of type PodcastEntity
      return podcastWithEpisodesSubscribed;
    } catch (e) {
      /// 4. Error. Return error message of type String
      return e.toString();
    }
  }

  @override
  Future<List<PodcastEntity>> unsubscribeFromPodcast(
      PodcastEntity podcast) async {
    podcastBox.remove(podcast.id);
    return await podcastDataSources.getSubscribedPodcasts() ?? [];
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
}
