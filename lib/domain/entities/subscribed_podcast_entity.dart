import 'dart:typed_data';

// Parameters not yet final
class SubscribedPodcastEntity {
  final Uint8List? artwork;
  final String url;
  final int unreadEpisodes; // will be length of episodes where read == false

  SubscribedPodcastEntity({
    required this.artwork,
    required this.url,
    required this.unreadEpisodes,
  });
}
