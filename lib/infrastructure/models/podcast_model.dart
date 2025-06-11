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
    // Helper to safely extract values from JSON with default values and HTML stripping
    String? parseHtmlText(dynamic value) {
      if (value == null) return null;
      if (value is String && value.contains('<')) {
        return parse(value).documentElement?.text;
      }
      return value.toString();
    }

    int? tryParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    bool? tryParseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is int) return value == 1; // We assume 1 corresponds to true
      return null;
    }

    return PodcastModel(
      pId: tryParseInt(json['id']) ?? -1, // Use -1 as invalid ID
      podcastGuid: json['podcastGuid'] as String?,
      title: parseHtmlText(json['title']) ?? "",
      url: json['url'] as String? ?? "",
      link: json['link'] as String?, // stays nullable
      description: parseHtmlText(json['description']) ?? "",
      author: parseHtmlText(json['author']) ?? "",
      ownerName: parseHtmlText(json['ownerName']) ?? "",
      artwork: (json['artwork'] ?? json['image']) as String? ?? "", // artwork OR image
      lastUpdateTime: tryParseInt(json['lastUpdateTime']) ?? tryParseInt(json['newestItemPubdate']) ?? tryParseInt(json['newestItemPublishTime']),
      language: json['language'] as String? ?? "",
      explicit: tryParseBool(json['explicit']), // stays nullable
      medium: json['medium'] as String?, // stays nullable
      episodeCount: tryParseInt(json['episodeCount']), // stays nullable
      categories: (json['categories'] != null) ? _categoryValuesToList(json['categories'] as Map<String, dynamic>) : [],
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
    );
  }
}
