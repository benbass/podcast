import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../core/globals.dart';
import '../../domain/entities/persistent_podcast_settings_entity.dart';
import '../../domain/entities/podcast_entity.dart';
import '../../domain/entities/podcast_filter_settings_entity.dart';

part 'podcast_settings_state.dart';

class PodcastSettingsCubit extends Cubit<PodcastSettingsState> {
  PodcastSettingsCubit() : super(PodcastSettingsInitial());

  Future<void> loadSettings(int id) async {
    emit(PodcastSettingsLoading());

    /// 1. load the persistent settings
    try {
      final podcast = podcastBox.get(id);
      if (podcast == null) {
        emit(PodcastSettingsError("Podcast not found."));
        return;
      }

      PersistentPodcastSettingsEntity? persistentSettings =
          podcast.persistentSettings.target;

      if (persistentSettings == null) {
        persistentSettings = PersistentPodcastSettingsEntity(
          podcastId: podcast.pId,
          filterExplicitEpisodes: false,
          filterTrailerEpisodes: false,
          filterBonusEpisodes: false,
          minEpisodeDurationMinutes: null,
        );
        settingsBox.put(persistentSettings);
        // Relate the settings to the podcast and save the podcast again to persist the relationship
        podcast.persistentSettings.target = persistentSettings;
        podcastBox.put(podcast);
      }

      /// 2. create a state with the persistent settings and default filter settings
      final filterSettingsForState = PodcastFilterSettingsEntity(
        podcastId: podcast.pId,
        filterExplicitEpisodes: persistentSettings.filterExplicitEpisodes,
        filterTrailerEpisodes: persistentSettings.filterTrailerEpisodes,
        filterBonusEpisodes: persistentSettings.filterBonusEpisodes,
        minEpisodeDurationMinutes: persistentSettings.minEpisodeDurationMinutes,
        // default filter settings
        filterRead: true,
        showOnlyUnfinished: false,
        showOnlyFavorites: false,
        showOnlyDownloaded: false,
        filterByText: false,
        transientSearchText: null,
        sortProperty: EpisodeSortProperty.datePublished,
        sortDirection: SortDirection.descending,
      );

      /// 3. emit the state
      emit(PodcastSettingsLoaded(filterSettingsForState, podcast));
    } catch (e) {
      emit(PodcastSettingsError("Error loading the settings."));
    }
  }

  Future<void> updatePersistentSettings({
    bool? filterExplicitEpisodes,
    bool? filterTrailerEpisodes,
    bool? filterBonusEpisodes,
    int? minEpisodeDurationMinutes,
  }) async {
    final currentState = state;
    if (currentState is PodcastSettingsLoaded) {
      PersistentPodcastSettingsEntity? persistentSettings =
          currentState.podcast.persistentSettings.target;

      if (persistentSettings == null) {
        // Should never happen, but just in case
        emit(PodcastSettingsError(
            "Cannot update settings. Settings were not found."));
        // Try to load the settings again
        loadSettings(currentState.podcast.id);
        return;
      }

      bool changed = false;
      if (filterExplicitEpisodes != null &&
          persistentSettings.filterExplicitEpisodes != filterExplicitEpisodes) {
        persistentSettings.filterExplicitEpisodes = filterExplicitEpisodes;
        changed = true;
      }
      if (filterTrailerEpisodes != null &&
          persistentSettings.filterTrailerEpisodes != filterTrailerEpisodes) {
        persistentSettings.filterTrailerEpisodes = filterTrailerEpisodes;
        changed = true;
      }
      if (filterBonusEpisodes != null &&
          persistentSettings.filterBonusEpisodes != filterBonusEpisodes) {
        persistentSettings.filterBonusEpisodes = filterBonusEpisodes;
        changed = true;
      } else if (minEpisodeDurationMinutes != null &&
          persistentSettings.minEpisodeDurationMinutes !=
              minEpisodeDurationMinutes) {
        persistentSettings.minEpisodeDurationMinutes =
            minEpisodeDurationMinutes;
        changed = true;
      }

      if (changed) {
        try {
          settingsBox.put(persistentSettings);

          // Create a new PodcastFilterSettingsEntity with the updated persistent settings
          final newFilterSettingsForState = currentState.settings.copyWith(
            filterExplicitEpisodes: persistentSettings.filterExplicitEpisodes,
            filterTrailerEpisodes: persistentSettings.filterTrailerEpisodes,
            filterBonusEpisodes: persistentSettings.filterBonusEpisodes,
            minEpisodeDurationMinutes:
                persistentSettings.minEpisodeDurationMinutes,
          );
          emit(PodcastSettingsLoaded(
              newFilterSettingsForState, currentState.podcast));
        } catch (e) {
          emit(PodcastSettingsError(
              "Fehler beim Speichern der Einstellungen."));
        }
      }
    } else {
      // Do something when current state is not PodcastSettingsLoaded or not for the right podcast?
      // Should never happen!
    }
  }

  Future<void> updateUiFilterSettings({
    bool? filterRead,
    bool? showOnlyUnfinished,
    bool? showOnlyFavorites,
    bool? showOnlyDownloaded,
    EpisodeSortProperty? sortProperty,
    SortDirection? sortDirection,
    String? transientSearchText,
    bool? filterByText,
  }) async {
    final currentState = state;
    if (currentState is PodcastSettingsLoaded) {
      final newFilterSettings = currentState.settings.copyWith(
        filterRead: filterRead,
        showOnlyUnfinished: showOnlyUnfinished,
        showOnlyFavorites: showOnlyFavorites,
        showOnlyDownloaded: showOnlyDownloaded,
        sortProperty: sortProperty,
        sortDirection: sortDirection,
        transientSearchText: transientSearchText,
        filterByText: filterByText,
      );

      if (newFilterSettings != currentState.settings) {
        emit(PodcastSettingsLoaded(newFilterSettings, currentState.podcast));
      }
    } else {}
  }
  /// END fluctuating filter settings

  Future<void> loadSettingsForPodcast(PodcastEntity podcast) async {
    loadSettings(podcast.id);
  }

  // This method is used by the EpisodesBloc while being created to get the *current* settings before the stream starts.
  PodcastFilterSettingsEntity? getSettingsForPodcast(int podcastId) {
    if (state is PodcastSettingsLoaded) {
      final loadedState = state as PodcastSettingsLoaded;
      if (loadedState.podcast.pId == podcastId) {
        return loadedState.settings;
      }
    }
    return null;
  }

  Future<void> updateSettingsForPodcast(
      PodcastEntity podcast, PodcastFilterSettingsEntity newSettings) async {
    // Speichere die neuen Einstellungen
    // await _saveSettingsToPrefs(podcast.pId, newSettings);
    emit(PodcastSettingsLoaded(newSettings, podcast));
  }
}
