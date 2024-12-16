import 'package:html/parser.dart';
import 'podcast_entity.dart';

class PodcastQuery {
  final int count;
  final String query;
  final String description;
  final List<PodcastEntity> podcasts;

  PodcastQuery({
    required this.count,
    required this.query,
    required this.description,
    required this.podcasts,
  });

  factory PodcastQuery.fromJson(Map<String, dynamic> json) {
    return PodcastQuery(
      count: json['count'] ?? 0,
      query: json['query'] ?? "",
      description: parse(json['description']).documentElement?.text ?? "",
      podcasts: List<PodcastEntity>.from(json['feeds'].map((x) => PodcastEntity.fromJson(x))),
    );
  }
}
