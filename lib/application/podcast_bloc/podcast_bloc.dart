import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:podcast/core/globals.dart';

import '../../domain/entities/podcast_entity.dart';
import '../../domain/usecases/episode_usecases.dart';
import '../../domain/usecases/podcast_usecases.dart';

part 'podcast_event.dart';
part 'podcast_state.dart';

class PodcastBloc extends Bloc<PodcastEvent, PodcastState> {
  final PodcastUseCases podcastUseCases;
  final EpisodeUseCases episodeUseCases;
  PodcastBloc({
    required this.podcastUseCases,
    required this.episodeUseCases,
  }) : super(
          PodcastState.initial(),
        ) {
    /// LOCAL
    on<LoadSubscribedPodcastsEvent>(_onLoadSubscribedPodcastsEvent);
    on<SubscribeToPodcastEvent>(_onSubscribeToPodcastEvent);
    on<UnSubscribeFromPodcastEvent>(_onUnSubscribeToPodcastEvent);
    on<UpdateQueryEvent>(_onUpdateQueryEvent);

    /// END LOCAL

    /// REMOTE
    on<FetchTrendingPodcastsEvent>(_onFetchTrendingPodcastsEvent);
    on<GetRemotePodcastsByKeywordEvent>(_onGetRemotePodcastsByKeywordEvent);

    /// END REMOTE

    on<PodcastTappedEvent>(_onPodcastTappedEvent);
    on<ToggleStateToSuccessAfterFailureEvent>(
        _onToggleStateToSuccessAfterFailureEvent);
  }

  FutureOr<void> _onLoadSubscribedPodcastsEvent(event, emit) async {
    emit(state.copyWith(status: PodcastStatus.loading));
    try {
      final List<PodcastEntity> subscribedPodcasts =
          await podcastUseCases.getSubscribedPodcasts();
      emit(state.copyWith(
        status: PodcastStatus.success,
        subscribedPodcasts: subscribedPodcasts,
      ));
      add(FetchTrendingPodcastsEvent());
    } catch (e) {
      emit(state.copyWith(status: PodcastStatus.failure));
    }
  }

  // FutureOr here because subscribing also fetches the episodes from remote
  // if they are missing before saving to database
  FutureOr<void> _onSubscribeToPodcastEvent(event, emit) async {
    emit(state.copyWith(status: PodcastStatus.loading));
    try {
      // Save to db
      await podcastUseCases.subscribeToPodcast(event.podcast);

      // update subscribed podcasts list with latest db version
      List<PodcastEntity> subscribedPodcasts =
          await podcastUseCases.getSubscribedPodcasts();

      // Current podcast (emitted by prior PodcastTappedEvent) is from query result.
      // Its id is 0 since this object is not in the database.
      // Now that podcast has been added to the database with an id != 0,
      // we replace the current podcast with the one from the database:
      PodcastEntity currentPodcast =
          podcastBox.get(subscribedPodcasts.last.id)!;

      emit(state.copyWith(
        status: PodcastStatus.success,
        subscribedPodcasts: subscribedPodcasts,
        currentPodcast: currentPodcast,
      ));
      // We also need to update the query result with the podcast from db that will be displayed as subscribed
      add(UpdateQueryEvent());
    } catch (e) {
      emit(state.copyWith(status: PodcastStatus.failure));
    }
  }

  Future<void> _onUnSubscribeToPodcastEvent(event, emit) async {
    emit(state.copyWith(status: PodcastStatus.loading));
    try {
      PodcastEntity unsubscribedPodcast = state.currentPodcast.copyWith(
        subscribed: false,
      );
      await podcastUseCases.unsubscribeFromPodcast(state.currentPodcast);
      List<PodcastEntity> subscribedPodcasts =
          await podcastUseCases.getSubscribedPodcasts();
      // Fetch trending podcasts again in case the unsubscribed podcast appears in trending so we show now the remote one
      List<PodcastEntity> trendingPodcasts =
      await podcastUseCases.fetchTrendingPodcasts();
      emit(state.copyWith(
        subscribedPodcasts: subscribedPodcasts,
        currentPodcast: unsubscribedPodcast,
        trendingPodcasts: trendingPodcasts,
        status: PodcastStatus.success,
      ));
      add(UpdateQueryEvent());
    } catch (e) {
      emit(state.copyWith(status: PodcastStatus.failure));
    }
  }

  Future<void> _onUpdateQueryEvent(event, emit) async {
    List<PodcastEntity> updatedList = await podcastUseCases.updatedQueryResult(
      state.queryResultPodcasts,
      state.currentPodcast,
    );
    emit(state.copyWith(
      queryResultPodcasts: updatedList,
    ));
  }

  FutureOr<void> _onGetRemotePodcastsByKeywordEvent(event, emit) async {
    emit(state.copyWith(status: PodcastStatus.loading));
    try {
      List<PodcastEntity> queryResult =
          await podcastUseCases.fetchPodcasts(event.keyword);
      emit(state.copyWith(
        status: PodcastStatus.success,
        queryResultPodcasts: queryResult,
      ));
    } catch (e) {
      emit(state.copyWith(status: PodcastStatus.failure));
    }
  }

  Future<void> _onPodcastTappedEvent(event, emit) async {
    emit(state.copyWith(status: PodcastStatus.loading));
    if (!event.podcast.subscribed) {
      final PodcastEntity podcast =
          await podcastUseCases.savePodcastAndArtwork(event.podcast);
      emit(state.copyWith(
        status: PodcastStatus.success,
        currentPodcast: podcast,
      ));
    } else {
      emit(state.copyWith(
        status: PodcastStatus.success,
        currentPodcast: event.podcast,
      ));
    }
  }

  FutureOr<void> _onFetchTrendingPodcastsEvent(event, emit) async {
    emit(state.copyWith(status: PodcastStatus.loading));
    try {
      List<PodcastEntity> trendingPodcasts =
          await podcastUseCases.fetchTrendingPodcasts();
      emit(state.copyWith(
        status: PodcastStatus.success,
        trendingPodcasts: trendingPodcasts,
      ));
    } catch (e) {
      emit(state.copyWith(status: PodcastStatus.failure));
    }
  }

  FutureOr<void> _onToggleStateToSuccessAfterFailureEvent(event, emit) async {
    emit(state.copyWith(status: PodcastStatus.success));
  }
}
