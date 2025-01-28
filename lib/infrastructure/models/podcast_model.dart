import 'package:html/parser.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';

class PodcastModel extends PodcastEntity {
  PodcastModel({
    required super.pId,
    required super.podcastGuid,
    required super.title,
    required super.url,
    required super.link,
    required super.description,
    required super.author,
    required super.ownerName,
    required super.artwork,
    required super.lastUpdateTime,
    required super.language,
    required super.explicit,
    required super.medium,
    required super.episodeCount,
    required super.categories,
    required super.subscribed,
  });

  factory PodcastModel.fromJson(Map<String, dynamic> json) {
    return PodcastModel(
      pId: json['id'],
      podcastGuid: json['podcastGuid'],
      title: parse(json['title']).documentElement?.text ?? "",
      url: json['url'] ?? "",
      link: json['link'] ?? "",
      description: parse(json['description']).documentElement?.text ?? "",
      author: parse(json['author']).documentElement?.text ?? "",
      ownerName: parse(json['ownerName']).documentElement?.text ?? "",
      artwork: json['artwork'] ?? "",
      lastUpdateTime: json['lastUpdateTime'] ?? 0,
      language: json['language'] ?? "",
      explicit: json['explicit'] ?? false,
      medium: json['medium'] ?? "",
      episodeCount: json['episodeCount'] ?? 0,
      categories: json['categories'] != null
          ? Map<String, String>.from(json['categories'])
          : {},
      subscribed: false,
    );
  }

}
