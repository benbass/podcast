import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../core/globals.dart';
import '../../../domain/entities/episode_entity.dart';
import '../../../domain/entities/user_playlist_entity.dart';
import '../../../objectbox.g.dart';

part 'user_playlist_state.dart';

class UserPlaylistCubit extends Cubit<UserPlaylistState> {
  UserPlaylistCubit() : super(UserPlaylistInitial());

  static List<UserPlaylistEntity> userPlaylists = userPlaylistBox.getAll();

  Future<void> loadPlaylist() async {
    emit(UserPlaylistLoading());
    try {
      UserPlaylistEntity? playlist = userPlaylistBox.get(globalPlaylistId);

      if (playlist == null) {
        playlist = UserPlaylistEntity(
          id: globalPlaylistId,
          episodeIds: [],
        );

        userPlaylistBox.put(playlist);
      }

      if (playlist.episodeIds.isEmpty) {
        emit(UserPlaylistLoaded(
          userPlaylist: const [],
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

      emit(UserPlaylistLoaded(
        userPlaylist: List<EpisodeEntity>.from(episodeEntities),
        autoPlayEnabled: playlist.autoPlayEnabled,
      ));
    } catch (e) {
      emit(UserPlaylistError("Error loading the playlist."));
    }
  }

  Future<void> addEpisodeIdsToPlaylist(List<int> episodeIdsToAdd) async {
    emit(UserPlaylistLoading());

    try {
      final UserPlaylistEntity playlist =
          userPlaylistBox.get(globalPlaylistId) ??
              UserPlaylistEntity(id: globalPlaylistId, episodeIds: []);

      // Prevent duplicates
      final newEpisodeIds = episodeIdsToAdd
          .where((id) => !playlist.episodeIds.contains(id))
          .toList();

      if (newEpisodeIds.isEmpty) {
        // Episodes already in playlist
        emit(UserPlaylistMessage("Episode(s) already in playlist."));
        return;
      }

      playlist.episodeIds.addAll(newEpisodeIds);
      userPlaylistBox.put(playlist);

      final List<EpisodeEntity?> allPlaylistEpisodes =
          episodeBox.getMany(playlist.episodeIds);
      final List<EpisodeEntity> allEpisodeEntities =
          allPlaylistEpisodes.whereType<EpisodeEntity>().toList();

      emit(UserPlaylistLoaded(
        userPlaylist: List<EpisodeEntity>.from(allEpisodeEntities),
        autoPlayEnabled: playlist.autoPlayEnabled,
      ));
    } catch (e) {
      emit(UserPlaylistError("Error adding episode(s) to playlist."));
    }
  }

  Future<void> removeEpisodeIdFromPlaylist(int episodeId) async {
    emit(UserPlaylistLoading());
    try {
      final UserPlaylistEntity? playlist =
          userPlaylistBox.get(globalPlaylistId);

      if (playlist == null) {
        emit(UserPlaylistError("Playlist not found. Cannot remove episode."));
        return;
      }

      final bool wasRemoved = playlist.episodeIds.remove(episodeId);

      if (!wasRemoved) {
        emit(UserPlaylistMessage("Episode not found in playlist."));
        await loadPlaylist();
        return;
      }

      userPlaylistBox.put(playlist);

      final List<EpisodeEntity?> allPlaylistEpisodes =
          episodeBox.getMany(playlist.episodeIds);
      final List<EpisodeEntity> allEpisodeEntities =
          allPlaylistEpisodes.whereType<EpisodeEntity>().toList();

      emit(UserPlaylistLoaded(
        userPlaylist: allEpisodeEntities,
        autoPlayEnabled: playlist.autoPlayEnabled,
      ));
    } catch (e) {
      emit(UserPlaylistError("Error removing episode from playlist."));
    }
  }

  Future<void> reorderPlaylist(int oldIndex, int newIndex) async {
    try {
      UserPlaylistEntity? playlist = userPlaylistBox.get(globalPlaylistId);

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

      userPlaylistBox.put(playlist);
      final List<EpisodeEntity?> allPlaylistEpisodes =
          episodeBox.getMany(playlist.episodeIds);

      emit(UserPlaylistLoaded(
        userPlaylist: List<EpisodeEntity>.from(allPlaylistEpisodes),
        autoPlayEnabled: playlist.autoPlayEnabled,
      ));
    } catch (e) {
      emit(UserPlaylistError("Error reordering playlist."));
      loadPlaylist();
    }
  }

  Future<void> clearPlaylist() async {
    emit(UserPlaylistLoading());
    try {
      final UserPlaylistEntity? playlist =
          userPlaylistBox.get(globalPlaylistId);

      if (playlist == null) {
        return;
      }

      playlist.episodeIds.clear();
      userPlaylistBox.put(playlist);

      emit(UserPlaylistLoaded(
        userPlaylist: const [],
        autoPlayEnabled: playlist.autoPlayEnabled,
      ));
    } catch (e) {
      emit(UserPlaylistError("Error clearing playlist."));
    }
  }

  Future<void> updatePersistentSettings(bool enabled) async {
    try {
      final UserPlaylistEntity? playlist =
          userPlaylistBox.get(globalPlaylistId);
      if (playlist == null) {
        return;
      }
      playlist.autoPlayEnabled = enabled;
      userPlaylistBox.put(playlist);

      final List<EpisodeEntity?> allPlaylistEpisodes =
          episodeBox.getMany(playlist.episodeIds);

      emit(UserPlaylistLoaded(
        userPlaylist: List<EpisodeEntity>.from(allPlaylistEpisodes),
        autoPlayEnabled: enabled,
      ));
    } catch (e) {
      emit(UserPlaylistError("Error updating autoplay setting."));
    }
  }

  Future<void> removeEpisodeIdsByFeed({required int feedId}) async {
    // Get the playlist
    UserPlaylistEntity? playlist = userPlaylistBox.get(globalPlaylistId);

    if (playlist != null && playlist.episodeIds.isNotEmpty) {
      // Get all episode objects from db by feedID and build a set from their ids
      final idsQueryBuilder =
          episodeBox.query(EpisodeEntity_.feedId.equals(feedId)).build();
      final episodeIds = idsQueryBuilder.findIds().toSet();

      // Remove all ids from the playlist that are in the set
      playlist.episodeIds.removeWhere((id) => episodeIds.contains(id));
      // Save the playlist
      userPlaylistBox.put(playlist);
    }
  }
}
