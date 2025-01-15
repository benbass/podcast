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

  /// Additional data for user prefs and info (for subscribed podcasts)
  final bool favorite;
  final bool read;
  final bool completed;
  final int position;

  /// downloaded file (subscribed or not!), if applicable
  final String filePath;

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
    required this.filePath,
  });

  EpisodeEntity copyWith( {
    bool? favorite,
    bool? read,
    bool? completed,
    int? position,
    String? filePath,
  }) {
    return EpisodeEntity(
      pId: pId,
      title: title,
      description: description,
      guid: guid,
      datePublished: datePublished,
      datePublishedPretty: datePublishedPretty,
      enclosureUrl: enclosureUrl,
      enclosureLength: enclosureLength,
      duration: duration,
      explicit: explicit,
      episodeNr: episodeNr,
      episodeType: episodeType,
      season: season,
      image: image,
      feedUrl: feedUrl,
      link: link,
      feedImage: feedImage,
      feedId: feedId,
      podcastGuid: podcastGuid,
      favorite: favorite ?? this.favorite,
      read: read ?? this.read,
      completed: completed ?? this.completed,
      position: position ?? this.position,
      filePath: filePath ?? this.filePath,
    );
  }
}
