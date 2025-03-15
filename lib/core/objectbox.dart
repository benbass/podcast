import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:podcast/core/globals.dart';
import '../domain/entities/episode_entity.dart';
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

  Stream<List<EpisodeEntity>> getEpisodes(int feedId) {
    final qBuilderEpisodes = episodeBox.query(EpisodeEntity_.feedId.equals(feedId)).order(EpisodeEntity_.datePublished, flags: Order.descending);
    return qBuilderEpisodes.watch(triggerImmediately: true).map((query) => query.find());
  }

  EpisodeEntity getEpisode(int id) => episodeBox.get(id)!;

}
