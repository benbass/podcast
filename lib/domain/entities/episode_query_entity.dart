import 'package:html/parser.dart';
import 'package:podcast/domain/entities/episode_entity.dart';

class EpisodeQuery {
  final int count;
  final String query;
  final String description;
  final List<EpisodeEntity> episodes;

  EpisodeQuery({
    required this.count,
    required this.query,
    required this.description,
    required this.episodes,
  });

  factory EpisodeQuery.fromJson(Map<String, dynamic> json) {
    return EpisodeQuery(
      count: json['count'] ?? 0,
      query: json['query'] ?? "",
      description: parse(json['description']).documentElement?.text ?? "",
      episodes: List<EpisodeEntity>.from(
          json['items'].map((x) => EpisodeEntity.fromJson(x))),
    );
  }
}
