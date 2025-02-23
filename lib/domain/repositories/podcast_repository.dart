import 'package:podcast/domain/entities/podcast_entity.dart';

abstract class PodcastRepository {
  Future<List<PodcastEntity>> fetchPodcastsByKeywords(String keyword);
  Future<dynamic> subscribeToPodcast(PodcastEntity podcast);
  Future<List<PodcastEntity>>  unsubscribeFromPodcast(PodcastEntity podcast);
  Future<List<PodcastEntity>?> getSubscribedPodcasts();
  Future<PodcastEntity> fillPodcastWithEpisodes(PodcastEntity podcast);
}