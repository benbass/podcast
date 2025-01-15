import '../entities/subscribed_podcast_entity.dart';

abstract class SubscribedPodcastRepository {
  Future<List<SubscribedPodcastEntity>> getSubscribedPodcastsFromDb();
}