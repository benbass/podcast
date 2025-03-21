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
      final List<EpisodeEntity> newEpisodes = await episodeUseCases
          .newEpisodesList(feedId: state.currentPodcast.pId);
      if (newEpisodes.isNotEmpty) {
        PodcastEntity podcast = podcastBox.get(state.currentPodcast.id)!;
        podcast.episodes.insertAll(0, newEpisodes);
        podcast.episodes.applyToDb();
        final List<EpisodeEntity> updatedLocalEpisodes = await episodeUseCases
            .getEpisodes(
              subscribed: true,
              feedId: podcast.pId,
              showRead: state.areReadEpisodesVisible,
            )
            .first;
        emit(state.copyWith(
          status: PodcastStatus.success,
          episodes: updatedLocalEpisodes,
          //currentPodcast: podcast,
        ));
      } else {
        emit(state.copyWith(
          status: PodcastStatus.success,
        ));
      }
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
      final List<EpisodeEntity> stream = await episodeUseCases
          .getEpisodes(
            subscribed: state.currentPodcast.subscribed,
            feedId: state.currentPodcast.pId,
            showRead: false,
          )
          .first;
      emit(state.copyWith(
        status: PodcastStatus.success,
        episodes: stream,
      ));
    } catch (e) {
      emit(state.copyWith(status: PodcastStatus.failure));
    }
  }
}
