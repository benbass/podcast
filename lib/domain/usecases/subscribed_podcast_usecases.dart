import '../entities/subscribed_podcast_entity.dart';
import '../repositories/subscribed_podcast_repository.dart';

class SubscribedPodcastUseCases{
  final SubscribedPodcastRepository subscribedPodcastRepository;

  const SubscribedPodcastUseCases({
    required this.subscribedPodcastRepository,
  });

  Future<List<SubscribedPodcastEntity>> getSubscribedPodcasts() async {
    return subscribedPodcastRepository.getSubscribedPodcastsFromDb();
  }
}