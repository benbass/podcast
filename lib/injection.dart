import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:podcast/domain/repositories/podcast_repository.dart';
import 'package:podcast/domain/usecases/podcast_usecases.dart';
import 'package:podcast/helpers/listeners/player_listener.dart';
import 'package:podcast/helpers/player/audiohandler.dart';
import 'package:podcast/infrastructure/repositories/podcast_repository_impl.dart';

import 'application/episode_playback_cubit/episode_playback_cubit.dart';
import 'application/podcast_bloc/podcast_bloc.dart';
import 'application/textfield_cubit/text_field_cubit.dart';
import 'domain/repositories/episode_repository.dart';
import 'domain/usecases/episode_usecases.dart';
import 'helpers/core/connectivity_manager.dart';
import 'infrastructure/datasources/episode_datasources.dart';
import 'infrastructure/datasources/podcast_datasources.dart';
import 'infrastructure/repositories/episode_repository_impl.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // State management
  getIt.registerFactory(() => PodcastBloc(
        podcastUseCases: getIt(),
        episodeUseCases: getIt(),
      ));
  getIt.registerFactory(() => TextFieldCubit());
  getIt.registerFactory(() => EpisodePlaybackCubit());

  // Use cases
  getIt
      .registerLazySingleton(() => PodcastUseCases(podcastRepository: getIt()));
  getIt
      .registerLazySingleton(() => EpisodeUseCases(episodeRepository: getIt()));

  // Repos
  getIt.registerLazySingleton<PodcastRepository>(() => PodcastRepositoryImpl(
        podcastDataSources: getIt(),
        episodeDataSources: getIt(),
      )); // remote (fetching)
  getIt.registerLazySingleton<EpisodeRepository>(() => EpisodeRepositoryImpl(
        episodeRemoteDataSource: getIt(),
        episodeLocalDatasource: getIt(),
      ));

  // DataSources
  getIt.registerLazySingleton<PodcastDataSource>(
      () => PodcastDataSourceImpl(httpClient: getIt())); // remote
  getIt.registerLazySingleton<EpisodeRemoteDataSource>(
      () => EpisodeRemoteDataSourceImpl(httpClient: getIt()));
  getIt.registerLazySingleton<EpisodeLocalDatasource>(
      () => EpisodeLocalDatasourceImpl());

  // Extern
  getIt.registerLazySingleton(() => http.Client());

  // Core
  getIt.registerLazySingleton(() => ConnectivityManager());
  getIt.registerLazySingleton<MyAudioHandler>(() => MyAudioHandler());
  getIt.registerLazySingleton<PlayerStatesListener>(() => PlayerStatesListener());
}
