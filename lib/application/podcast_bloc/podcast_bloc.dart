import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:podcast/core/globals.dart';

import '../../domain/entities/episode_entity.dart';
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
    on<GetUnreadEpisodesByFeedIdEvent>(_onGetUnreadEpisodesByFeedIdEvent);
    on<ToggleUnreadEpisodesVisibilityEvent>(
        _onToggleUnreadEpisodesVisibilityEvent);
    on<SubscribeToPodcastEvent>(_onSubscribeToPodcastEvent);
    on<UnSubscribeFromPodcastEvent>(_onUnSubscribeToPodcastEvent);
    on<UpdateQueryEvent>(_onUpdateQueryEvent);

    /// END LOCAL

    /// REMOTE
    on<GetRemotePodcastsByKeywordEvent>(_onGetRemotePodcastsByKeywordEvent);
    on<RefreshEpisodesByFeedIdEvent>(_onRefreshEpisodesByFeedIdEvent);

    /// END REMOTE

    /// LOCAL and REMOTE
    on<GetEpisodesByFeedIdEvent>(_onGetEpisodesByFeedIdEvent);

    /// END LOCAL and REMOTE

    on<PodcastTappedEvent>(_onPodcastTappedEvent);
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
      // Get the Stream from the use case
      /* final stream = podcastUseCases.getSubscribedPodcasts();
      // Listen to the Stream and update the state with the new data
      await emit.forEach<List<PodcastEntity>>(
        stream,
        onData: (data) {
          emit(state.copyWith(
            status: PodcastStatus.success,
            subscribedPodcasts: data,
          ));
        },
        onError: (error, stackTrace) {
          emit(state.copyWith(status: PodcastStatus.failure));
        },
      );*/
    } catch (e) {
      emit(state.copyWith(status: PodcastStatus.failure));
    }
  }

  FutureOr<void> _onGetUnreadEpisodesByFeedIdEvent(event, emit) async {
    emit(state.copyWith(status: PodcastStatus.loading));
    try {
      // Get the Stream from the use case
      final stream = episodeUseCases.getEpisodes(
        subscribed: true,
        feedId: state.currentPodcast.pId,
        onlyUnread: true,
      );
      // Listen to the Stream and update the state with the new data
      await emit.forEach<List<EpisodeEntity>>(
        stream,
        onData: (data) {
          emit(state.copyWith(
            status: PodcastStatus.success,
            episodes: data,
          ));
        },
        onError: (error, stackTrace) {
          emit(state.copyWith(status: PodcastStatus.failure));
        },
      );
    } catch (e) {
      emit(state.copyWith(status: PodcastStatus.failure));
    }
  }

  void _onToggleUnreadEpisodesVisibilityEvent(event, emit) {
    emit(state.copyWith(areReadEpisodesVisible: event.areReadEpisodesVisible));
  }

  // FutureOr here because subscribing also fetches the episodes from remote
  // if they are missing before saving to database
  FutureOr<void> _onSubscribeToPodcastEvent(event, emit) async {
    emit(state.copyWith(status: PodcastStatus.loading));
    try {
      await podcastUseCases.subscribeToPodcast(event.podcast);
      List<PodcastEntity> subscribedPodcasts =
          await podcastUseCases.getSubscribedPodcasts();
      // Current podcast (emitted by prior PodcastTappedEvent is from query result.
      // Its id is 0 since this object is not in the database.
      // Now that podcast has been added to the database with an id != 0 and saved episodes
      // we replace the current podcast with the one from the database:
      PodcastEntity currentPodcast =
          podcastBox.get(subscribedPodcasts.last.id)!;
      emit(state.copyWith(
        status: PodcastStatus.success,
        subscribedPodcasts: subscribedPodcasts,
        currentPodcast: currentPodcast,
      ));
    } catch (e) {
      emit(state.copyWith(status: PodcastStatus.failure));
    }
  }

  Future<void> _onUnSubscribeToPodcastEvent(event, emit) async {
    emit(state.copyWith(status: PodcastStatus.loading));
    try {
      // We want to keep this podcast with all its episodes in case user navigates back to the episode list
      PodcastEntity unsubscribedPodcast = state.currentPodcast.copyWith(
        subscribed: false,
      )..episodes.addAll(
          state.currentPodcast.episodes,
        );
      await podcastUseCases.unsubscribeFromPodcast(state.currentPodcast);
      List<PodcastEntity> subscribedPodcasts =
          await podcastUseCases.getSubscribedPodcasts();
      emit(state.copyWith(
        subscribedPodcasts: subscribedPodcasts,
        currentPodcast: unsubscribedPodcast,
        status: PodcastStatus.success,
      ));
      add(UpdateQueryEvent(feedId: state.currentPodcast.pId));
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
    emit(state.copyWith(status: PodcastStatus.loading, keyword: event.keyword));
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

  FutureOr<void> _onRefreshEpisodesByFeedIdEvent(event, emit) async {
    emit(state.copyWith(status: PodcastStatus.loading));
    try {
      List<EpisodeEntity> updatedEpisodes = await episodeUseCases
          .refreshEpisodes(podcast: state.currentPodcast)
          .first;
      emit(state.copyWith(
        status: PodcastStatus.success,
        episodes: updatedEpisodes,
        currentPodcast: state.currentPodcast.copyWith()
          ..episodes.addAll(updatedEpisodes),
      ));
    } catch (e) {
      emit(state.copyWith(status: PodcastStatus.failure));
    }
  }

  Future<void> _onPodcastTappedEvent(event, emit) async {
    emit(state.copyWith(
      currentPodcast: event.podcast,
      episodes: event.podcast.episodes,
    ));
  }

  FutureOr<void> _onGetEpisodesByFeedIdEvent(event, emit) async {
    emit(state.copyWith(status: PodcastStatus.loading));
    try {
      final stream = episodeUseCases.getEpisodes(
        subscribed: state.currentPodcast.subscribed,
        feedId: state.currentPodcast.pId,
        onlyUnread: false,
      );
      await emit.forEach<List<EpisodeEntity>>(stream, onData: (data) {
        emit(state.copyWith(
          status: PodcastStatus.success,
          episodes: data,
        ));
      }, onError: (error, stackTrace) {
        emit(state.copyWith(status: PodcastStatus.failure));
      });
    } catch (e) {
      emit(state.copyWith(status: PodcastStatus.failure));
    }
  }
}
