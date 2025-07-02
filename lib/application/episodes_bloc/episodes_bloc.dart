import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/domain/entities/podcast_filter_settings_entity.dart';

import '../../core/error/failure.dart';
import '../../domain/usecases/episode_usecases.dart';
import '../podcast_settings_cubit/podcast_settings_cubit.dart';

part 'episodes_event.dart';
part 'episodes_state.dart';

class EpisodesBloc extends Bloc<EpisodesEvent, EpisodesState> {
  final EpisodeUseCases episodeUseCases;
  final PodcastSettingsCubit? podcastSettingsCubit;
  StreamSubscription<List<EpisodeEntity>>? _episodesSubscription;
  StreamSubscription<PodcastSettingsState>? _settingsSubscription;

  EpisodesBloc({
    required this.episodeUseCases,
    this.podcastSettingsCubit, // Will be injected when available
  }) : super(const EpisodesState()) {
    on<LoadEpisodes>(_onLoadEpisodes);
    on<_EpisodesUpdated>(_onEpisodesUpdated);
    on<_FilterSettingsChanged>(_onFilterSettingsChanged);
    on<RefreshEpisodes>(_onRefreshEpisodes);
    on<NotificationShownEvent>(_onNotificationShown);

    // Listen to PodcastSettingsCubit when it's available
    _settingsSubscription =
        podcastSettingsCubit?.stream.listen((settingsState) {
      if (settingsState is PodcastSettingsLoaded) {
        if (state.status != EpisodesStatus.initial &&
            state.feedId != null &&
            state.feedId == settingsState.podcast.feedId) {
          add(_FilterSettingsChanged(settingsState.settings));
        }
      }
    });
  }

  Future<void> _onLoadEpisodes(
      LoadEpisodes event, Emitter<EpisodesState> emit) async {
    // If a stream for the same feed is already running, only update filters
    if (state.feedId == event.feedId &&
        state.status != EpisodesStatus.initial) {
      emit(state.copyWith(
        isSubscribed: event.isSubscribed,
        activeFilters: event.initialFilterSettings ?? state.activeFilters,
        status: EpisodesStatus.loading,
      ));
    } else {
      emit(state.copyWith(
        status: EpisodesStatus.loading,
        feedId: event.feedId,
        isSubscribed: event.isSubscribed,
        activeFilters: event.initialFilterSettings,
        episodes: [],
      ));
    }

    await _episodesSubscription?.cancel();
    _episodesSubscription = episodeUseCases
        .getEpisodesStream(
      feedId: event.feedId,
      isSubscribed: event.isSubscribed,
      filterSettings: event.initialFilterSettings!,
    )
        .listen(
      (episodes) => add(_EpisodesUpdated(episodes)),
      onError: (error) {
        emit(state.copyWith(
          status: EpisodesStatus.failure,
          errorMessage:
              error is Failure ? error.message : "Failed to load episodes",
        ));
      },
    );
  }

  void _onEpisodesUpdated(_EpisodesUpdated event, Emitter<EpisodesState> emit) {
    emit(state.copyWith(
      status: EpisodesStatus.success,
      episodes: event.episodes,
    ));
  }

  Future<void> _onFilterSettingsChanged(
      _FilterSettingsChanged event, Emitter<EpisodesState> emit) async {
    if (state.feedId == null) {
      return;
    }

    emit(state.copyWith(
        status: EpisodesStatus.loading, activeFilters: event.newSettings));

    await _episodesSubscription?.cancel();
    _episodesSubscription = episodeUseCases
        .getEpisodesStream(
      feedId: state.feedId!,
      isSubscribed: state.isSubscribed,
      filterSettings: event.newSettings,
    )
        .listen(
      (episodes) => add(_EpisodesUpdated(episodes)),
      onError: (error) {
        emit(state.copyWith(
          status: EpisodesStatus.failure,
          errorMessage: error is Failure
              ? error.message
              : "Failed to update episodes with new filters",
        ));
      },
    );
  }

  Future<void> _onRefreshEpisodes(
      RefreshEpisodes event, Emitter<EpisodesState> emit) async {
    final int countBeforeRefresh = state.episodes.length;
    emit(state.copyWith(status: EpisodesStatus.refreshing));
    try {
      await episodeUseCases.refreshEpisodesFromServer(
        feedId: event.feedId,
      );

      final List<EpisodeEntity> currentEpisodesAfterRefresh =
          await episodeUseCases
              .getEpisodesStream(
                  feedId: event.feedId,
                  isSubscribed: state.isSubscribed,
                  filterSettings: state.activeFilters!)
              .first;

      final int finalCountBeforeRefresh = countBeforeRefresh;
      final int finalCountAfterRefresh = currentEpisodesAfterRefresh.length;

      final int diff = finalCountAfterRefresh - finalCountBeforeRefresh;

      emit(state.copyWith(
        status: EpisodesStatus.success,
        episodes: currentEpisodesAfterRefresh,
        newlyAddedCount: diff,
        wasRefreshOperation: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: EpisodesStatus.failure,
        errorMessage:
            error is Failure ? error.message : "Failed to refresh episodes",
      ));
    }
  }

  void _onNotificationShown(
      NotificationShownEvent event, Emitter<EpisodesState> emit) {
    emit(state.copyWith(
        clearNewlyAddedCount: true, clearWasRefreshOperation: true));
  }

  @override
  Future<void> close() {
    _episodesSubscription?.cancel();
    _settingsSubscription?.cancel();
    return super.close();
  }
}
