import 'package:get_it/get_it.dart';
import 'package:podcast/domain/repositories/podcast_repository.dart';
import 'package:podcast/helpers/player/audiohandler.dart';
import 'package:podcast/infrastructure/repositories/podcast_repository_impl.dart';

import 'domain/repositories/episode_repository.dart';
import 'infrastructure/datasources/episode_datasources.dart';
import 'infrastructure/datasources/podcast_datasources.dart';
import 'infrastructure/repositories/episode_repository_impl.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Repos
  sl.registerLazySingleton<PodcastRepository>(() =>
      PodcastRepositoryImpl(
          podcastDataSources: sl()));
  sl.registerLazySingleton<EpisodeRepository>(
          () => EpisodeRepositoryImpl(episodeDataSources: sl()));

  // DataSources
  sl.registerLazySingleton<PodcastDataSources>(
      () => PodcastDataSourceImpl());
  sl.registerLazySingleton<EpisodeDataSources>(
          () => EpisodeDataSourcesImpl());

  // Core
  sl.registerLazySingleton<MyAudioHandler>(() => MyAudioHandler());
}
