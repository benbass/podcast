import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../core/globals.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/playlist_entity.dart';

part 'playlist_details_state.dart';

class PlaylistDetailsCubit extends Cubit<PlaylistDetailsState> {
  PlaylistDetailsCubit() : super(PlaylistDetailsInitial());

  static List<AppPlaylist> playlists = playlistBox.getAll();

  Future<void> loadPlaylist() async {
    emit(PlaylistDetailsLoading());
    try {
      AppPlaylist? playlist = playlistBox.get(globalPlaylistId);

      if (playlist == null) {
        playlist = AppPlaylist(
          id: globalPlaylistId,
          episodeIds: [],
        );

        playlistBox.put(playlist);
      }

      if (playlist.episodeIds.isEmpty) {
        emit(PlaylistDetailsLoaded(
          const [],
          playlist.currentPlayingIndex,
          playlist.autoPlayEnabled,
        ));
        return;
      }

      final List<EpisodeEntity?> episodes =
          episodeBox.getMany(playlist.episodeIds);

      final List<EpisodeEntity> episodeEntities =
          episodes.whereType<EpisodeEntity>().toList();
      // Sort? May be necessary if objectBox getMany() does not keep the order of the episodes in the playlist.
      // In that case order the episodes as in playlist.episodeIds!

      emit(PlaylistDetailsLoaded(
        List<EpisodeEntity>.from(episodeEntities),
        playlist.currentPlayingIndex,
        playlist.autoPlayEnabled,
      ));
    } catch (e) {
      emit(PlaylistDetailsError("Error loading the playlist."));
    }
  }

  Future<void> addEpisodeToPlaylist(List<int> episodeIdsToAdd) async {
    emit(PlaylistDetailsLoading());

    try {
      final AppPlaylist playlist = playlistBox.get(globalPlaylistId) ??
          AppPlaylist(id: globalPlaylistId, episodeIds: []);

      // Prevent duplicates
      final newEpisodeIds = episodeIdsToAdd
          .where((id) => !playlist.episodeIds.contains(id))
          .toList();

      if (newEpisodeIds.isEmpty) {
        // Episodes already in playlist
        emit(PlaylistDetailsInfo("Episode(s) already in playlist."));
        return;
      }

      playlist.episodeIds.addAll(newEpisodeIds);
      playlistBox.put(playlist);

      final List<EpisodeEntity?> allPlaylistEpisodes =
          episodeBox.getMany(playlist.episodeIds);
      final List<EpisodeEntity> allEpisodeEntities =
          allPlaylistEpisodes.whereType<EpisodeEntity>().toList();

      emit(PlaylistDetailsLoaded(List<EpisodeEntity>.from(allEpisodeEntities),
          playlist.currentPlayingIndex, playlist.autoPlayEnabled));
    } catch (e) {
      emit(PlaylistDetailsError("Error adding episode(s) to playlist."));
    }
  }

  Future<void> removeEpisodeFromPlaylist(int episodeId) async {
    emit(PlaylistDetailsLoading());
    try {
      final AppPlaylist? playlist = playlistBox.get(globalPlaylistId);

      if (playlist == null) {
        emit(
            PlaylistDetailsError("Playlist not found. Cannot remove episode."));
        return;
      }

      final int indexOfRemovedEpisode = playlist.episodeIds.indexOf(episodeId);
      final bool wasRemoved = playlist.episodeIds.remove(episodeId);

      if (!wasRemoved) {
        emit(PlaylistDetailsInfo("Episode not found in playlist."));
        await loadPlaylist();
        return;
      }

      // Update currentPlayingIndex
      if (playlist.episodeIds.isEmpty) {
        playlist.currentPlayingIndex = null;
      } else if (playlist.currentPlayingIndex != null) {
        if (indexOfRemovedEpisode < playlist.currentPlayingIndex!) {
          playlist.currentPlayingIndex = playlist.currentPlayingIndex! - 1;
        } else if (indexOfRemovedEpisode == playlist.currentPlayingIndex!) {
          if (playlist.currentPlayingIndex! >= playlist.episodeIds.length) {
            playlist.currentPlayingIndex = playlist.episodeIds.isNotEmpty
                ? playlist.episodeIds.length - 1
                : null;
          }
        }
      }

      if (playlist.currentPlayingIndex != null &&
          (playlist.currentPlayingIndex! < 0 ||
              playlist.currentPlayingIndex! >= playlist.episodeIds.length)) {
        playlist.currentPlayingIndex = null;
      }

      playlistBox.put(playlist);

      if (playlist.episodeIds.isEmpty) {
        emit(PlaylistDetailsLoaded(
            const [], playlist.currentPlayingIndex, playlist.autoPlayEnabled));
        return;
      }

      final List<EpisodeEntity?> allPlaylistEpisodes =
          episodeBox.getMany(playlist.episodeIds);
      final List<EpisodeEntity> allEpisodeEntities =
          allPlaylistEpisodes.whereType<EpisodeEntity>().toList();

      emit(PlaylistDetailsLoaded(List<EpisodeEntity>.from(allEpisodeEntities),
          playlist.currentPlayingIndex, playlist.autoPlayEnabled));
    } catch (e) {
      emit(PlaylistDetailsError("Error removing episode from playlist."));
    }
  }

  Future<void> reorderPlaylist(int oldIndex, int newIndex) async {
    try {
      AppPlaylist? playlist = playlistBox.get(globalPlaylistId);

      if (playlist == null) {
        return;
      }

      if (oldIndex < 0 ||
          oldIndex >= playlist.episodeIds.length ||
          newIndex < 0 ||
          newIndex > playlist.episodeIds.length) {
        debugPrint(
            "Error: Invalid indices for reordering. Old: $oldIndex, New: $newIndex, Length: ${playlist.episodeIds.length}");
        await loadPlaylist();
        return;
      }

      int adjustedNewIndex = newIndex;
      if (oldIndex < newIndex) {
        adjustedNewIndex = newIndex - 1;
      }

      final int episodeIdToMove = playlist.episodeIds.removeAt(oldIndex);
      playlist.episodeIds.insert(adjustedNewIndex, episodeIdToMove);

      // --- Update currentPlayingIndex ---
      if (playlist.currentPlayingIndex != null) {
        int currentIndex = playlist.currentPlayingIndex!;

        if (oldIndex == currentIndex) {
          playlist.currentPlayingIndex = adjustedNewIndex;
        } else {
          if (oldIndex < currentIndex && adjustedNewIndex >= currentIndex) {
            playlist.currentPlayingIndex = currentIndex - 1;
          } else if (oldIndex > currentIndex &&
              adjustedNewIndex <= currentIndex) {
            playlist.currentPlayingIndex = currentIndex + 1;
          }
        }
      }
      // --- End Update currentPlayingIndex ---

      playlistBox.put(playlist);

      final List<EpisodeEntity?> allPlaylistEpisodes =
          episodeBox.getMany(playlist.episodeIds);
      final List<EpisodeEntity> allEpisodeEntities = [];

      // In case getMany() does not keep the order of the episodes in the playlist or returns nulls
      Map<int, EpisodeEntity> episodeMap = {
        for (var ep in allPlaylistEpisodes.whereType<EpisodeEntity>())
          ep.eId: ep
      };
      for (var id in playlist.episodeIds) {
        if (episodeMap.containsKey(id)) {
          allEpisodeEntities.add(episodeMap[id]!);
        }
      }

      emit(PlaylistDetailsLoaded(List<EpisodeEntity>.from(allEpisodeEntities),
          playlist.currentPlayingIndex, playlist.autoPlayEnabled));
    } catch (e) {
      emit(PlaylistDetailsError("Error reordering playlist."));
      loadPlaylist();
    }
  }

  Future<void> clearPlaylist() async {
    emit(PlaylistDetailsLoading());
    try {
      final AppPlaylist? playlist = playlistBox.get(globalPlaylistId);

      if (playlist == null) {
        return;
      }

      playlist.episodeIds.clear();
      playlist.currentPlayingIndex = null;
      playlistBox.put(playlist);

      emit(PlaylistDetailsLoaded(
          const [], playlist.currentPlayingIndex, playlist.autoPlayEnabled));
    } catch (e) {
      emit(PlaylistDetailsError("Error clearing playlist."));
    }
  }

  Future<void> setAutoplay(bool enabled) async {
    try {
      final AppPlaylist? playlist = playlistBox.get(globalPlaylistId);
      if (playlist == null) {
        return;
      }
      playlist.autoPlayEnabled = enabled;
      playlistBox.put(playlist);

      if (state is PlaylistDetailsLoaded) {
        final currentState = state as PlaylistDetailsLoaded;
        emit(PlaylistDetailsLoaded(
          currentState.playlist,
          currentState.currentPlayingIndex,
          playlist.autoPlayEnabled,
        ));
      } else {
        // Fallback just in case
        final List<EpisodeEntity?> allPlaylistEpisodes =
            episodeBox.getMany(playlist.episodeIds);
        final List<EpisodeEntity> allEpisodeEntities =
            allPlaylistEpisodes.whereType<EpisodeEntity>().toList();
        emit(PlaylistDetailsLoaded(List<EpisodeEntity>.from(allEpisodeEntities),
            playlist.currentPlayingIndex, playlist.autoPlayEnabled));
      }
    } catch (e) {
      emit(PlaylistDetailsError("Error setting autoplay."));
    }
  }

  Future<void> setCurrentPlayingIndex(int? index) async {
    try {
      final AppPlaylist? playlist = playlistBox.get(globalPlaylistId);

      if (playlist == null) {
        return;
      }

      // Validate index
      if (index != null && (index < 0 || index >= playlist.episodeIds.length)) {
        emit(PlaylistDetailsError("Invalid playback index provided."));
        return;
      } else {
        playlist.currentPlayingIndex = index;
      }

      playlist.currentPlayingIndex = index;
      playlistBox.put(playlist);

      if (state is PlaylistDetailsLoaded) {
        final currentState = state as PlaylistDetailsLoaded;
        emit(PlaylistDetailsLoaded(
          currentState.playlist,
          playlist.currentPlayingIndex,
          currentState.autoPlayEnabled,
        ));
      } else {
        // Fallback just in case
        final List<EpisodeEntity?> allPlaylistEpisodes =
            episodeBox.getMany(playlist.episodeIds);
        final List<EpisodeEntity> allEpisodeEntities =
            allPlaylistEpisodes.whereType<EpisodeEntity>().toList();
        emit(PlaylistDetailsLoaded(List<EpisodeEntity>.from(allEpisodeEntities),
            playlist.currentPlayingIndex, playlist.autoPlayEnabled));
      }
    } catch (e) {
      emit(PlaylistDetailsError("Error setting current playing index."));
    }
  }
}
