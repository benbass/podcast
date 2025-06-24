import 'package:objectbox/objectbox.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';

import '../domain/entities/persistent_podcast_settings_entity.dart';
import '../domain/entities/playlist_entity.dart';
import 'objectbox.dart';

const String baseUrl = 'https://api.podcastindex.org/api/1.0';
late ObjectBox objectBox;
late Box<PodcastEntity> podcastBox;
late Box<EpisodeEntity> episodeBox;
late Box<PersistentPodcastSettingsEntity> settingsBox;
late Box<AppPlaylist> playlistBox;
const String kCurrentDownloadFilePath = "current_download_filepath";
const int globalPlaylistId = 1;

