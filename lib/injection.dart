import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:podcast/domain/repositories/podcast_repository.dart';
import 'package:podcast/domain/usecases/podcast_usecases.dart';
import 'package:podcast/helpers/listeners/player_listener.dart';
import 'package:podcast/helpers/player/audiohandler.dart';
import 'package:podcast/infrastructure/repositories/podcast_repository_impl.dart';

import 'application/episodes/episode_selection_cubit/episode_selection_cubit.dart';
import 'application/episodes/episodes_bloc/episodes_bloc.dart';
import 'application/episodes/textfield_cubit/text_field_cubit.dart';
import 'application/playback/playback_cubit/playback_cubit.dart';
import 'application/podcast/podcast_bloc/podcast_bloc.dart';
import 'application/podcast/podcast_settings_cubit/podcast_settings_cubit.dart';
import 'application/user_playlist/user_playlist_cubit/user_playlist_cubit.dart';
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
  getIt.registerFactory(() => PodcastSettingsCubit());
  getIt.registerFactory(() => EpisodesBloc(episodeUseCases: getIt(), podcastSettingsCubit: getIt()));
  getIt.registerFactory(() => PlaybackCubit());
  getIt.registerFactory(() => EpisodeSelectionCubit());
  getIt.registerFactory(() => UserPlaylistCubit());
  getIt.registerFactory(() => TextFieldCubit());

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
        episodeLocalDatasource: getIt(),
        episodeRemoteDatasource: getIt(),
      ));

  // DataSources
  getIt.registerLazySingleton<PodcastDataSource>(
      () => PodcastDataSourceImpl(httpClient: getIt())); // remote
  getIt.registerLazySingleton<EpisodeRemoteDataSource>(
      () => EpisodeRemoteDataSourceImpl(httpClient: getIt())); // remote, used by EpisodeLocalDatasourceImpl only
  getIt.registerLazySingleton<EpisodeLocalDatasource>(
      () => EpisodeLocalDatasourceImpl()); // local

  // Extern
  getIt.registerLazySingleton(() => http.Client());

  // Core
  getIt.registerLazySingleton(() => ConnectivityManager());
  getIt.registerLazySingleton<MyAudioHandler>(() => MyAudioHandler());
  getIt.registerLazySingleton<PlayerStatesListener>(() => PlayerStatesListener());
}
