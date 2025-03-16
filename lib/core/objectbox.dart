import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:podcast/core/globals.dart';
import '../domain/entities/episode_entity.dart';
import '../domain/entities/podcast_entity.dart';
import '../infrastructure/datasources/episode_datasources.dart';
import '../injection.dart';
import '../objectbox.g.dart'; // created by `flutter pub run build_runner build`

class ObjectBox {
  /// The Store of this app.
  late final Store store;

  ObjectBox._create(this.store) {
    // Add any additional setup code, e.g. build queries.
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // method Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore(directory: p.join(docsDir.path, "obx-podcasts"));
    return ObjectBox._create(store);
  }

  Stream<List<EpisodeEntity>> getEpisodes({required PodcastEntity podcast, required bool onlyUnread}){
    if(podcast.subscribed){
      if(onlyUnread) {
        return getLocalUnreadEpisodesByFeedId(podcast.pId);
      } else {
        return getLocalEpisodesByFeedId(podcast.pId);
      }
    } else{
      return getItI<EpisodeDataSources>().fetchEpisodesAsStreamByFeedId(podcast.pId);
    }
  }

  Stream<List<EpisodeEntity>> getLocalUnreadEpisodesByFeedId(int feedId) {
    final queryBuilder = episodeBox.query(EpisodeEntity_.feedId.equals(feedId).and(EpisodeEntity_.read.equals(false)))..order(EpisodeEntity_.datePublished, flags: Order.descending);
    return queryBuilder.watch(triggerImmediately: true).map((query) => query.find());
  }

  Stream<List<EpisodeEntity>> getLocalEpisodesByFeedId(int feedId) {
    final queryBuilder = episodeBox.query(EpisodeEntity_.feedId.equals(feedId))..order(EpisodeEntity_.datePublished, flags: Order.descending);
    return queryBuilder.watch(triggerImmediately: true).map((query) => query.find());
  }

  Stream<int> unreadEpisodesCount({required int feedId}){
    final queryBuilder = episodeBox.query(EpisodeEntity_.feedId.equals(feedId).and(EpisodeEntity_.read.equals(false)));
    return queryBuilder.watch(triggerImmediately: true).map((query) => query.count());
  }

  EpisodeEntity getEpisode(int id) => episodeBox.get(id)!;

}
