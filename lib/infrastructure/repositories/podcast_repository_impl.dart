import 'package:podcast/core/globals.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/infrastructure/datasources/episode_datasources.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/repositories/podcast_repository.dart';
import '../datasources/podcast_datasources.dart';

class PodcastRepositoryImpl implements PodcastRepository {
  final PodcastDataSources podcastDataSources;
  final EpisodeDataSources episodeDataSources;
  const PodcastRepositoryImpl({
    required this.podcastDataSources,
    required this.episodeDataSources,
  });

  @override
  Future<List<PodcastEntity>> fetchPodcastsByKeywords(String keyword) async {
    return await podcastDataSources.fetchPodcastsByKeywords(keyword);
  }

  @override
  Future<void> subscribeToPodcast(PodcastEntity podcast) async {
    podcastBox.put(podcast);
  }

  @override
  Future<void> unsubscribeFromPodcast(PodcastEntity podcast) async {
    podcastBox.remove(podcast.id);
  }

  @override
  Future<List<PodcastEntity>> getSubscribedPodcasts() async {
    List<PodcastEntity> podcasts = podcastBox.getAll();
    return podcasts;
  }

  @override
  Future<PodcastEntity> fillPodcastWithEpisodes(PodcastEntity podcast) async {
    final Stream<List<EpisodeEntity>> episodes =
        episodeDataSources.fetchEpisodesAsStreamByFeedId(podcast.pId);
    final List<EpisodeEntity> episodesList = await episodes.first;
    for (EpisodeEntity episode in episodesList) {
      podcast.episodes.add(episode);
    }
    return podcast;
  }

}
