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
    required super.artworkFilePath,
    required episodes,
  });

  /// Converts a map of categories to a list of strings representing the category names.
  ///
  /// ObjectBox, the database being used, doesn't support storing maps directly.
  /// Therefore, we need to convert the category map into a list of strings.
  ///
  /// This method takes a map of categories, extracts the category names (values),
  /// and returns them as a list of strings.
  static List<String> _categoryValuesToList(
      Map<String, dynamic> categoriesJson) {
    if (categoriesJson.isEmpty) {
      return [];
    }
    // Ensure that the values are strings
    return categoriesJson.values.whereType<String>().toList();
  }

  /// Creates a [PodcastModel] instance from a JSON map.
  ///
  /// This factory constructor parses the JSON data, extracts relevant information,
  /// and constructs a [PodcastModel] object.
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
      artworkFilePath: null,
      episodes: [],
    );
  }

  /// Converts explicitly! the [PodcastModel] instance to a [PodcastEntity].
  ///
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
      artworkFilePath: artworkFilePath,
    );
  }
}
