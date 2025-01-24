import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:podcast/application/podcasts_bloc/podcasts_bloc.dart';
import 'package:podcast/domain/repositories/podcast_repository.dart';
import 'package:podcast/domain/usecases/podcast_usecases.dart';
import 'package:podcast/helpers/player/audiohandler.dart';
import 'package:podcast/infrastructure/repositories/podcast_repository_impl.dart';

import 'application/episodes_bloc/episodes_bloc.dart';
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

final getItI = GetIt.instance;

Future<void> init() async {
   // State management
  getItI.registerFactory(
      () => SubscribedPodcastsBloc(subscribedPodcastUseCases: getItI()));
  getItI.registerFactory(() => PodcastsBloc(podcastUseCases: getItI()));
  getItI.registerFactory(() => EpisodesBloc(episodeUseCases: getItI()));

  // Use cases
  getItI.registerLazySingleton(
      () => SubscribedPodcastUseCases(subscribedPodcastRepository: getItI()));
  getItI.registerLazySingleton(() => PodcastUseCases(podcastRepository: getItI()));
  getItI.registerLazySingleton(() => EpisodeUseCases(episodeRepository: getItI()));

  // Repos
  getItI.registerLazySingleton<PodcastRepository>(() =>
      PodcastRepositoryImpl(podcastDataSources: getItI())); // remote (fetching)
  getItI.registerLazySingleton<SubscribedPodcastRepository>(() =>
      SubscribedPodcastsRepositoryImpl(
          subscribedPodcastsDataSources: getItI())); // local from DB
  getItI.registerLazySingleton<EpisodeRepository>(
          () => EpisodeRepositoryImpl(episodeDataSources: getItI()));

  // DataSources
  getItI.registerLazySingleton<PodcastDataSources>(
          () => PodcastDataSourceImpl(httpClient: getItI())); // remote
  getItI.registerLazySingleton<SubscribedPodcastsDataSources>(
          () => SubscribedPodcastsDataSourcesImpl()); // local
  getItI.registerLazySingleton<EpisodeDataSources>(() => EpisodeDataSourcesImpl(httpClient: getItI()));

  // Extern
  getItI.registerLazySingleton(() => http.Client());

  // Core
  getItI.registerLazySingleton<MyAudioHandler>(() => MyAudioHandler());
}
