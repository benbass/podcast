import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/domain/repositories/podcast_repository.dart';

class PodcastUseCases {
  final PodcastRepository podcastRepository;

  PodcastUseCases({
    required this.podcastRepository,
  });

  Future<List<PodcastEntity>> fetchPodcasts(String keyword) async {
    return podcastRepository.fetchPodcastsByKeywords(keyword);
  }

  Future<dynamic> subscribeToPodcast(PodcastEntity podcast) async {
    return await podcastRepository.subscribeToPodcast(podcast);
  }

  Future<List<PodcastEntity>> unsubscribeFromPodcast(PodcastEntity podcast) async {
    return podcastRepository.unsubscribeFromPodcast(podcast);
  }

  Future<List<PodcastEntity>> getSubscribedPodcasts() async {
    return podcastRepository.getSubscribedPodcasts();
  }

  Future<PodcastEntity> fillPodcastWithEpisodes(PodcastEntity podcast) async {
    return podcastRepository.fillPodcastWithEpisodes(podcast);
  }
}