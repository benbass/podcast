import 'dart:typed_data';

class SubscribedPodcastEntity{
  final Uint8List? artwork;
  final String url;

  SubscribedPodcastEntity({
    required this.artwork,
    required this.url,
  });
}
