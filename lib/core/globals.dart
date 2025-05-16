import 'package:objectbox/objectbox.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';

import 'objectbox.dart';

const String baseUrl = 'https://api.podcastindex.org/api/1.0';
late ObjectBox objectBox;
late Box<PodcastEntity> podcastBox;
late Box<EpisodeEntity> episodeBox;
const String kCurrentDownloadFilePath = "current_download_filepath";

/// For testing: create a fake episode
DateTime now = DateTime.now();
int secondsSinceEpochUtc = now.millisecondsSinceEpoch ~/ 1000;
EpisodeEntity fakeEpisode = EpisodeEntity(
  eId: 9009090100,
  title: "FAKE EPISODE",
  description: "description",
  guid: "00098",
  datePublished: secondsSinceEpochUtc,
  datePublishedPretty: "null",
  enclosureUrl: "enclosureUrl",
  enclosureLength: 1994398,
  duration: 213242432,
  explicit: 0,
  episodeNr: 0,
  episodeType: null,
  season: null,
  image: "",
  feedUrl: "feedUrl",
  link: "link",
  feedImage: "",
  feedId: 202500000000, // podcast.pId,
  podcastGuid: "abcdefghFake", // podcast.podcastGuid,
  podcastTitle: "Podcast for TEST",
  isSubscribed: false,
  favorite: true,
  read: false,
  completed: false,
  position: 09789798,
  filePath: null,
);
