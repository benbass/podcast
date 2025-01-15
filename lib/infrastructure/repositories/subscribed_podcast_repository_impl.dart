import '../../domain/entities/subscribed_podcast_entity.dart';
import '../../domain/repositories/subscribed_podcast_repository.dart';
import '../datasources/subscribed_podcasts_datasources.dart';

class SubscribedPodcastsRepositoryImpl implements SubscribedPodcastRepository {
  final SubscribedPodcastsDataSources subscribedPodcastsDataSources;
  const SubscribedPodcastsRepositoryImpl({
    required this.subscribedPodcastsDataSources,
  });

  @override
  Future<List<SubscribedPodcastEntity>> getSubscribedPodcastsFromDb() async {
    return await subscribedPodcastsDataSources.getSubscribedPodcastsFromDb();
  }
}
