import 'package:get_it/get_it.dart';
import 'package:podcast/application/podcasts_bloc/podcasts_bloc.dart';
import 'package:podcast/domain/repositories/podcast_repository.dart';
import 'package:podcast/domain/usecases/podcast_usecases.dart';
import 'package:podcast/helpers/player/audiohandler.dart';
import 'package:podcast/infrastructure/repositories/podcast_repository_impl.dart';

import 'application/subscribed_podcasts_bloc/subscribed_podcasts_bloc.dart';
import 'domain/repositories/episode_repository.dart';
import 'domain/repositories/subscribed_podcast_repository.dart';
import 'domain/usecases/episode_usecases.dart';
import 'domain/usecases/subscribed_podcast_usecases.dart';
import 'infrastructure/datasources/episode_datasources.dart';
import 'infrastructure/datasources/podcast_datasources.dart';
import 'infrastructure/datasources/subscribed_podcasts_datasources.dart';
import 'infrastructure/repositories/episode_repository_impl.dart';
import 'infrastructure/repositories/subscribed_podcast_repository_impl.dart';

final sl = GetIt.instance; // sl = service locator

Future<void> init() async {
  // Repos
  sl.registerLazySingleton<PodcastRepository>(
      () => PodcastRepositoryImpl(podcastDataSources: sl())); // remote (fetching)
  sl.registerLazySingleton<SubscribedPodcastRepository>(() =>
      SubscribedPodcastsRepositoryImpl(subscribedPodcastsDataSources: sl()));  // local from DB
  sl.registerLazySingleton<EpisodeRepository>(
      () => EpisodeRepositoryImpl(episodeDataSources: sl()));

  // DataSources
  sl.registerLazySingleton<PodcastDataSources>(() => PodcastDataSourceImpl()); // remote
  sl.registerLazySingleton<SubscribedPodcastsDataSources>(
      () => SubscribedPodcastsDataSourcesImpl()); // local
  sl.registerLazySingleton<EpisodeDataSources>(() => EpisodeDataSourcesImpl());

  // State management
  sl.registerFactory(() => SubscribedPodcastsBloc(subscribedPodcastUseCases: sl()));
  sl.registerFactory(() => PodcastsBloc(podcastUseCases: sl()));

  // Use cases
  sl.registerLazySingleton(() => SubscribedPodcastUseCases(
    subscribedPodcastRepository: sl()));
  sl.registerLazySingleton(() => PodcastUseCases(
      podcastRepository: sl()));
  sl.registerLazySingleton(() => EpisodeUseCases(episodeRepository: sl()));

  // Core
  sl.registerLazySingleton<MyAudioHandler>(() => MyAudioHandler());
}
