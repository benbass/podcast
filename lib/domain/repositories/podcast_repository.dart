import 'package:podcast/domain/entities/podcast_entity.dart';

abstract class PodcastRepository {
  Future<List<PodcastEntity>> fetchPodcastsByKeywords(String keyword, List<PodcastEntity> subscribedPodcasts);
  Future<void> subscribeToPodcast(PodcastEntity podcast);
  Future<void> unsubscribeFromPodcast(PodcastEntity podcast);
  Future<List<PodcastEntity>> getSubscribedPodcasts();
  Future<PodcastEntity> fillPodcastWithEpisodes(PodcastEntity podcast);
}