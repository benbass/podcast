import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../domain/entities/subscribed_podcast_entity.dart';

abstract class SubscribedPodcastsDataSources {
  Future<List<SubscribedPodcastEntity>> getSubscribedPodcastsFromDb();
}

class SubscribedPodcastsDataSourcesImpl extends SubscribedPodcastsDataSources {
  @override
  Future<List<SubscribedPodcastEntity>> getSubscribedPodcastsFromDb() async {
    // We are creating an object for now and until we implement the DB.
    http.Response response = await http.get(
      Uri.parse(
          'https://www.rbb-online.de/content/dam/rbb/inf/Podcasts2022/rbb24_Inforadio_Podcast_Unterwegs_16_9.jpg.jpg/rendition=ard.jpg/size=1400x1400.jpg'),
    );
    Uint8List? artwork = response.bodyBytes;
    return [
      SubscribedPodcastEntity(artwork: artwork, url: "url", unreadEpisodes: 14),
      SubscribedPodcastEntity(artwork: artwork, url: "url2", unreadEpisodes: 3),
      SubscribedPodcastEntity(
          artwork: artwork, url: "url3", unreadEpisodes: 364),
    ];
  }
}
