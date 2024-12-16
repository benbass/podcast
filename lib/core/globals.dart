import 'package:objectbox/objectbox.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';

late Box<PodcastEntity> podcastBox;
late Box<EpisodeEntity> episodeBox;