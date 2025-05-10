import 'package:podcast/domain/entities/episode_entity.dart';

import '../../core/globals.dart';

void performActionOnEpisode(
  EpisodeEntity episode,
  String flag,
  dynamic value,
) {
  switch (flag) {
    case "favorite":
      episode.favorite = !value;
      episodeBox.put(episode);
      break;
    case "read":
      episode.read = !value;
      episodeBox.put(episode);
      break;
    case "download":
      episode.filePath = value;
      episodeBox.put(episode);
      break;
    case "delete":
      episode.filePath = value;
      episodeBox.put(episode);
      break;
    case "share":
      break;
    default:
  }
}
