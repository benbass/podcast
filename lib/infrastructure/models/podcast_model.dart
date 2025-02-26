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
    required super.unreadEpisodes,
    required episodes,
  });

  /// Converts a map of categories to a list of category names.
  /// because ObjectBox doesn't support maps so we need a List type in entity.
  /// This method extracts the values from the 'categories' map and returns them as a list of strings.
  static List<String> _categoryValuesToList(
      Map<String, dynamic> categoriesJson) {
    if (categoriesJson.isEmpty) {
      return [];
    }
    // Ensure that the values are strings
    return categoriesJson.values.whereType<String>().toList();
  }

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
          ? _categoryValuesToList(json['categories'])
          : [],
      subscribed: false,
      unreadEpisodes: null,
      episodes: [],
    );
  }

  PodcastEntity toPodcastEntity() {
    return PodcastEntity(
      pId: pId,
      podcastGuid: podcastGuid,
      title: title,
      url: url,
      link: link,
      description: description,
      author: author,
      ownerName: ownerName,
      artwork: artwork,
      lastUpdateTime: lastUpdateTime,
      language: language,
      explicit: explicit,
      medium: medium,
      episodeCount: episodeCount,
      categories: categories,
      subscribed: subscribed,
      unreadEpisodes: unreadEpisodes,
    );
  }
}
