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
          playlist: const [],
          autoPlayEnabled: playlist.autoPlayEnabled,
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
        playlist: List<EpisodeEntity>.from(episodeEntities),
        autoPlayEnabled: playlist.autoPlayEnabled,
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

      emit(PlaylistDetailsLoaded(
        playlist: List<EpisodeEntity>.from(allEpisodeEntities),
        autoPlayEnabled: playlist.autoPlayEnabled,
      ));
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

      final bool wasRemoved = playlist.episodeIds.remove(episodeId);

      if (!wasRemoved) {
        emit(PlaylistDetailsInfo("Episode not found in playlist."));
        await loadPlaylist();
        return;
      }

      playlistBox.put(playlist);

      final List<EpisodeEntity?> allPlaylistEpisodes =
          episodeBox.getMany(playlist.episodeIds);
      final List<EpisodeEntity> allEpisodeEntities =
          allPlaylistEpisodes.whereType<EpisodeEntity>().toList();

      emit(PlaylistDetailsLoaded(
        playlist: allEpisodeEntities,
        autoPlayEnabled: playlist.autoPlayEnabled,
      ));
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

      playlistBox.put(playlist);
      final List<EpisodeEntity?> allPlaylistEpisodes =
          episodeBox.getMany(playlist.episodeIds);

      emit(PlaylistDetailsLoaded(
        playlist: List<EpisodeEntity>.from(allPlaylistEpisodes),
        autoPlayEnabled: playlist.autoPlayEnabled,
      ));
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
      playlistBox.put(playlist);

      emit(PlaylistDetailsLoaded(
        playlist: const [],
        autoPlayEnabled: playlist.autoPlayEnabled,
      ));
    } catch (e) {
      emit(PlaylistDetailsError("Error clearing playlist."));
    }
  }

  Future<void> updatePersistentSettings(bool enabled) async {
    try {
      final AppPlaylist? playlist = playlistBox.get(globalPlaylistId);
      if (playlist == null) {
        return;
      }
      playlist.autoPlayEnabled = enabled;
      playlistBox.put(playlist);

      final List<EpisodeEntity?> allPlaylistEpisodes =
          episodeBox.getMany(playlist.episodeIds);

      emit(PlaylistDetailsLoaded(
        playlist: List<EpisodeEntity>.from(allPlaylistEpisodes),
        autoPlayEnabled: enabled,
      ));
    } catch (e) {
      emit(PlaylistDetailsError("Error updating autoplay setting."));
    }
  }
}
