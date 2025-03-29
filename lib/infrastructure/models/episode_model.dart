import 'package:html/parser.dart';
import 'package:podcast/domain/entities/episode_entity.dart';

import '../../helpers/core/format_pubdate_string.dart';

class EpisodeModel extends EpisodeEntity {
  EpisodeModel({
    required super.eId,
    required super.title,
    required super.description,
    required super.guid,
    required super.datePublished,
    required super.datePublishedPretty,
    required super.enclosureUrl,
    required super.enclosureLength,
    required super.duration,
    required super.explicit,
    required super.episodeNr,
    required super.episodeType,
    required super.season,
    required super.image,
    required super.feedUrl,
    required super.link,
    required super.feedImage,
    required super.feedId,
    required super.podcastGuid,
    required super.podcastTitle,
    required super.favorite,
    required super.read,
    required super.completed,
    required super.position,
    required super.filePath,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      eId: json['id'],
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
      season: json['season'] ?? 0,
      image: json['image'],
      feedUrl: json['feedUrl'],
      link: json['link'],
      feedImage: json['feedImage'],
      feedId: json['feedId'],
      podcastGuid: json['podcastGuid'],
      podcastTitle: "",
      favorite: false,
      read: false,
      completed: false,
      position: 0,
      filePath: null,
    );
  }

}
