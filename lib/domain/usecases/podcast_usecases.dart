import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/domain/repositories/podcast_repository.dart';

class PodcastUseCases{
  final PodcastRepository podcastRepository;

  PodcastUseCases({required this.podcastRepository});

  Future<List> getSubscribedPodcasts() async {
    // fake delay for UI to show progress indicator
    return Future.delayed(const Duration(seconds: 1), () => []);
  }

  Future<List<PodcastEntity>> fetchPodcasts(String keyword) async {
    return podcastRepository.fetchPodcastsByKeywords(keyword);
  }
}