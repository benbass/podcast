import 'package:html/parser.dart';
import 'package:objectbox/objectbox.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';

import '../../helpers/core/format_pubdate_string.dart';

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

  final podcast = ToOne<PodcastEntity>();

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

  factory EpisodeEntity.fromJson(Map<String, dynamic> json) {
    return EpisodeEntity(
      pId: json['id'],
      title: parse(json['title']).documentElement?.text ?? "",
      description: parse(json['description']).documentElement?.text ?? "",
      guid: json['guid'],
      datePublished: json['datePublished'], // timestamp
      datePublishedPretty: extractDataFromDateString(json['datePublishedPretty']),
      enclosureUrl: json['enclosureUrl'],
      enclosureLength: json['enclosureLength'],
      duration: json['duration'] ?? 0,
      explicit: json['explicit'],
      episodeNr: json['episode'] ?? 0,
      episodeType: json['episodeType'] ?? "",
      season: json['season'],
      image: json['image'],
      feedUrl: json['feedUrl'],
      link: json['link'],
      feedImage: json['feedImage'],
      feedId: json['feedId'],
      podcastGuid: json['podcastGuid'],
      favorite: false,
      read: false,
      completed: false,
      position: 0,
    );
  }
}
