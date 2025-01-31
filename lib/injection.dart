import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:podcast/application/podcasts_bloc/podcasts_bloc.dart';
import 'package:podcast/domain/repositories/podcast_repository.dart';
import 'package:podcast/domain/usecases/podcast_usecases.dart';
import 'package:podcast/helpers/player/audiohandler.dart';
import 'package:podcast/infrastructure/repositories/podcast_repository_impl.dart';

import 'domain/repositories/episode_repository.dart';
import 'domain/usecases/episode_usecases.dart';
import 'infrastructure/datasources/episode_datasources.dart';
import 'infrastructure/datasources/podcast_datasources.dart';
import 'infrastructure/repositories/episode_repository_impl.dart';

final getItI = GetIt.instance;

Future<void> init() async {
  // State management
  getItI.registerFactory(() => PodcastsBloc(
        podcastUseCases: getItI(),
        episodeUseCases: getItI(),
      ));

  // Use cases
  getItI.registerLazySingleton(
      () => PodcastUseCases(podcastRepository: getItI()));
  getItI.registerLazySingleton(
      () => EpisodeUseCases(episodeRepository: getItI()));

  // Repos
  getItI.registerLazySingleton<PodcastRepository>(() => PodcastRepositoryImpl(
        podcastDataSources: getItI(),
        episodeDataSources: getItI(),
      )); // remote (fetching)
  getItI.registerLazySingleton<EpisodeRepository>(
      () => EpisodeRepositoryImpl(episodeDataSources: getItI()));

  // DataSources
  getItI.registerLazySingleton<PodcastDataSources>(
      () => PodcastDataSourceImpl(httpClient: getItI())); // remote
  getItI.registerLazySingleton<EpisodeDataSources>(
      () => EpisodeDataSourcesImpl(httpClient: getItI()));

  // Extern
  getItI.registerLazySingleton(() => http.Client());

  // Core
  getItI.registerLazySingleton<MyAudioHandler>(() => MyAudioHandler());
}
