import '../../core/globals.dart';
import '../../objectbox.g.dart';

/// Clean database (not flagged episodes from unsubscribed podcasts) at app closing
deleteEpisodes(){
  final queryBuilder = episodeBox.query(EpisodeEntity_.isSubscribed
      .equals(false)
      .and(EpisodeEntity_.favorite.equals(false))
      .and(EpisodeEntity_.filePath.isNull())
      .and(EpisodeEntity_.position.equals(0)),
  ).build();
  final results = queryBuilder.findIds();
  episodeBox.removeMany(results);
}