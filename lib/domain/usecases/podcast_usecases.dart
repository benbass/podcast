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

  Future<PodcastEntity> fetchPodcastByFeedId(int feedId) async {
    return podcastRepository.fetchPodcastByFeedId(feedId);
  }

  Future<bool> subscribeToPodcast(PodcastEntity podcast) async {
    return await podcastRepository.subscribeToPodcast(podcast);
  }

  Future<void> unsubscribeFromPodcast(PodcastEntity podcast) async {
    return podcastRepository.unsubscribeFromPodcast(podcast);
  }

  Future<List<PodcastEntity>> getSubscribedPodcasts() async {
    return podcastRepository.getSubscribedPodcasts();
  }

  Future<List<PodcastEntity>> updatedQueryResult(queryResult, currentPodcast){
    return podcastRepository.updatedQueryResult(queryResult, currentPodcast);
  }
}