import 'package:objectbox/objectbox.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';

@Entity()
class EpisodeEntity {
  /// ObjectBox related
  @Id()
  int id = 0;

  /// Data from json
  // Episode related
  final int eId; // internal PodcastIndex.org Episode ID
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
  final String? episodeType; // full┃trailer┃bonus
  final int? season;
  final String image;

  // Podcast (feed) related
  final String link; // page. = link of podcast entity
  final String feedUrl; // xml. . = url of podcast entity
  final String feedImage; // = image of podcast entity
  final int feedId; // = id of podcast entity
  final String podcastGuid; // = podcastGuid of podcast entity
  // Manually added info:
  final String podcastTitle;

  /// Additional data for user prefs and info
  bool isSubscribed;
  bool favorite;
  bool read; // can be set to true and back to false by user. Automatically set to true when episode is completed
  bool completed; // automatically set to true when episode is completed
  int position;
  String? filePath; // downloaded file

  /// ObjectBox relation
  final podcast = ToOne<PodcastEntity>();

  EpisodeEntity({
    required this.eId,
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
    required this.podcastTitle,
    required this.isSubscribed,
    required this.favorite,
    required this.read,
    required this.completed,
    required this.position,
    required this.filePath,
  });

  EpisodeEntity copyWith({
    bool? isSubscribed,
    bool? favorite,
    bool? read,
    bool? completed,
    int? position,
    String? filePath,
    String? podcastTitle
  }) {
    return EpisodeEntity(
      eId: eId,
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
      isSubscribed: isSubscribed ?? this.isSubscribed,
      favorite: favorite ?? this.favorite,
      read: read ?? this.read,
      completed: completed ?? this.completed,
      position: position ?? this.position,
      filePath: filePath ?? this.filePath,
      podcastTitle: podcastTitle ?? this.podcastTitle,
    );
  }

  // Implement equality based on the unique ID
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is EpisodeEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
