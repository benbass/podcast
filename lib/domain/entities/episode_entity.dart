import 'package:objectbox/objectbox.dart';


@Entity()
class EpisodeEntity {
  @Id()
  int id = 0;

  /// Data from json
  // Episode related
  final int pId;
  final String title;
  final String description;
  final String guid;
  final int datePublished;
  final String datePublishedPretty;
  final String enclosureUrl;
  final int enclosureLength; // Length in bytes
  final int? duration;
  final int explicit; // 0=not explicit, 1=explicit
  final int? episodeNr;
  final String episodeType; // full┃trailer┃bonus
  final int? season;
  final String image;

  // Podcast (feed) related
  final String link; // page
  final String feedUrl; // xml
  final String feedImage;
  final int feedId;
  final String podcastGuid;

  /// Additional data for user prefs and info
  final bool favorite;
  final bool read;
  final bool completed;
  final int position;

  EpisodeEntity({
    required this.pId,
    required this.title,
    required this.description,
    required this.guid,
    required this.datePublished,
    required this.datePublishedPretty,
    required this.enclosureUrl,
    required this.enclosureLength,
    required this.duration,
    required this.explicit,
    required this.episodeNr,
    required this.episodeType,
    required this.season,
    required this.image,
    required this.feedUrl,
    required this.link,
    required this.feedImage,
    required this.feedId,
    required this.podcastGuid,
    required this.favorite,
    required this.read,
    required this.completed,
    required this.position,
  });

}
