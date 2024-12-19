
class PodcastEntity {
  final int id;
  final String podcastGuid;
  final String title;
  final String url; // xml
  final String link;
  final String description;
  final String author;
  final String ownerName;
  final String artwork;
  final int lastUpdateTime;
  final String language;
  final bool explicit;
  // Possible values for medium: https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#node-value-12
  final String medium;
  final int episodeCount;
  final Map<String, String> categories;

  PodcastEntity({
    required this.id,
    required this.podcastGuid,
    required this.title,
    required this.url,
    required this.link,
    required this.description,
    required this.author,
    required this.ownerName,
    required this.artwork,
    required this.lastUpdateTime,
    required this.language,
    required this.explicit,
    required this.medium,
    required this.episodeCount,
    required this.categories,
  });
}
