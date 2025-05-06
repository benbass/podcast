import 'package:podcast/domain/entities/podcast_entity.dart';

abstract class PodcastRepository {
  Future<List<PodcastEntity>> fetchPodcastsByKeywords(String keyword);
  Future<List<PodcastEntity>> fetchTrendingPodcasts();
  Future<PodcastEntity> fetchPodcastByFeedId(int feedId);
  Future<PodcastEntity> savePodcastAndArtwork(PodcastEntity podcast);
  Future<bool> subscribeToPodcast(PodcastEntity podcast);
  Future<void>  unsubscribeFromPodcast(PodcastEntity podcast);
  Future<List<PodcastEntity>> getSubscribedPodcasts();
  Future<List<PodcastEntity>> updatedQueryResult(queryResult, currentPodcast);
}