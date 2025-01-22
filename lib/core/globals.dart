import 'package:objectbox/objectbox.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';

const String baseUrl = 'https://api.podcastindex.org/api/1.0';
late Box<PodcastEntity> podcastBox;
late Box<EpisodeEntity> episodeBox;