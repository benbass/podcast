import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/domain/repositories/podcast_repository.dart';

class PodcastUseCases {
  final PodcastRepository podcastRepository;

  PodcastUseCases({
    required this.podcastRepository,
  });

  Future<List<PodcastEntity>> fetchPodcasts(String keyword, List<PodcastEntity> subscribedPodcasts) async {
    return podcastRepository.fetchPodcastsByKeywords(keyword, subscribedPodcasts);
  }

  Future<void> subscribeToPodcast(PodcastEntity podcast) async {
    await podcastRepository.subscribeToPodcast(podcast);
  }

  Future<void> unsubscribeFromPodcast(PodcastEntity podcast) async {
    await podcastRepository.unsubscribeFromPodcast(podcast);
  }

  Future<List<PodcastEntity>> getSubscribedPodcasts() async {
    return podcastRepository.getSubscribedPodcasts();
  }

  Future<PodcastEntity> fillPodcastWithEpisodes(PodcastEntity podcast) async {
    return podcastRepository.fillPodcastWithEpisodes(podcast);
  }
}