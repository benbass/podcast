import 'package:objectbox/objectbox.dart';

import 'episode_entity.dart';

@Entity()
class PodcastEntity {
  /// ObjectBox related
  @Id()
  int id = 0;

  /// Data from json
  final int
      pId; // internal PodcastIndex.org Feed ID. To be used for fetching episodes!
  final String? podcastGuid;
  final String title;
  final String url; // xml
  final String? link;
  final String description;
  final String author;
  final String? ownerName;
  final String artwork; //
  final int? lastUpdateTime;
  final String language;
  final bool? explicit;
  // Possible values for medium: https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#node-value-12
  final String? medium;
  final int? episodeCount;
  final List<String> categories;

  /// User parameter
  bool subscribed;

  // will be used for subscribed podcasts: artworkFilePath is artwork url file saved to device
  String? artworkFilePath;

  /// ObjectBox relation
  @Backlink('podcast')
  final episodes = ToMany<EpisodeEntity>();

  PodcastEntity({
    required this.pId,
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
    required this.subscribed,
    required this.artworkFilePath,
  });

  PodcastEntity copyWith({
    bool? subscribed,
    int? unreadEpisodes,
    String? artworkFilePath,
  }) {
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
      subscribed: subscribed ?? this.subscribed,
      artworkFilePath: artworkFilePath ?? this.artworkFilePath,
    );
  }

  factory PodcastEntity.emptyPodcast() => PodcastEntity(
        pId: -1,
        podcastGuid: '',
        title: '',
        url: '',
        link: '',
        description: '',
        author: '',
        ownerName: '',
        artwork: '',
        lastUpdateTime: 0,
        language: '',
        explicit: false,
        medium: '',
        episodeCount: 0,
        categories: [],
        subscribed: false,
        artworkFilePath: null,
      );
}
