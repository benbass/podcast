import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/helpers/player/audiohandler.dart';
import 'package:podcast/injection.dart';

import '../../../core/globals.dart';

part 'playback_state.dart';

class PlaybackCubit extends Cubit<PlaybackState> {
  PlaybackCubit() : super(const PlaybackState());

  Future<void> onPlay({
    required String origin,
    required EpisodeEntity episode,
    required List<EpisodeEntity> playlist,
    required bool isAutoplayEnabled,
    int? currentIndex,
    required bool isUserPlaylist,
  }) async {
    int index = 0;
    if (currentIndex == null) {
      index = playlist.indexWhere((e) => e.id == episode.id);
      if (index == -1) {
        return;
      }
    } else {
      index = currentIndex;
    }

    emit(state.copyWith(
      origin: origin,
      episode: episode,
      currentPlaylist: playlist,
      currentIndex: index,
      isAutoplayEnabled: isAutoplayEnabled,
      isUserPlaylist: isUserPlaylist,
      playbackStatus: PlaybackStatus.playing,
    ));
  }

  void onPlayPause() {
    emit(state.copyWith(
      playbackStatus: state.playbackStatus == PlaybackStatus.paused
          ? PlaybackStatus.playing
          : PlaybackStatus.paused,
    ));
  }

  void resetPlayback() {
    emit(state.clearEpisode());
  }

  void updateAutoPlay({required bool autoplayEnabled}) {
    emit(state.copyWith(
      isAutoplayEnabled: autoplayEnabled,
    ));
  }

  Future<bool> onPlayNext(bool? isAutoplayEnabled) async {
    final currentState = state;

    if (currentState.episode != null && isAutoplayEnabled == null) {
      await _saveEpisodePosition(currentState.episode!);
    }

    if (currentState.currentPlaylist.isNotEmpty &&
        currentState.currentIndex != null) {
      if (currentState.currentIndex! <
          currentState.currentPlaylist.length - 1) {
        final nextIndex = currentState.currentIndex! + 1;
        final nextEpisode = currentState.currentPlaylist[nextIndex];
        emit(state.copyWith(
          episode: nextEpisode,
          currentIndex: nextIndex,
        ));
        return true;
        // true: playback is handled by audioHandler that will also update the notification
      } else {
        resetPlayback();
        return false;
        // End of playlist reached
      }
    } else {
      return false;
    }
  }

  Future<bool> onPlayPrevious() async {
    final currentState = state;

    if (currentState.episode != null) {
      await _saveEpisodePosition(currentState.episode!);
    }

    if (currentState.currentPlaylist.isNotEmpty &&
        currentState.currentIndex != null) {
      if (currentState.currentIndex! > 0) {
        final prevIndex = currentState.currentIndex! - 1;
        final prevEpisode = currentState.currentPlaylist[prevIndex];
        emit(currentState.copyWith(
          episode: prevEpisode,
          currentIndex: prevIndex,
        ));
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<int> _saveEpisodePosition(EpisodeEntity episode) async {
    episode.position = getIt<MyAudioHandler>().player.position.inSeconds;
    return episodeBox.put(episode);
  }

  // Needed only when reordering episodes in the user playlist (podcast episode lists cannot be reordered)
  void updateCurrentPlayingIndexAfterReorderingEpisode({
    required int oldIndex,
    required int newIndex,
  }) {
    final List<EpisodeEntity> originalPlaylist =
        List.from(state.currentPlaylist);
    final int? originalCurrentPlayerIdx = state.currentIndex;

    if (oldIndex < 0 || oldIndex >= originalPlaylist.length) {
      return;
    }

    int finalIndexOfMovedItem = newIndex;
    if (oldIndex < newIndex) {
      finalIndexOfMovedItem = newIndex - 1;
    }

    if (oldIndex == finalIndexOfMovedItem) {
      return;
    }
    if (finalIndexOfMovedItem < 0 ||
        finalIndexOfMovedItem >= originalPlaylist.length) {
      return;
    }

    final EpisodeEntity movedEpisodeEntity = originalPlaylist[oldIndex];
    EpisodeEntity? originalPlayingEpisodeEntity;
    if (originalCurrentPlayerIdx != null &&
        originalCurrentPlayerIdx >= 0 &&
        originalCurrentPlayerIdx < originalPlaylist.length) {
      originalPlayingEpisodeEntity = originalPlaylist[originalCurrentPlayerIdx];
    }

    final List<EpisodeEntity> reorderedPlaylist = List.from(originalPlaylist);
    reorderedPlaylist.removeAt(oldIndex);
    reorderedPlaylist.insert(finalIndexOfMovedItem, movedEpisodeEntity);

    int? newCalculatedPlayerIdx;

    if (originalPlayingEpisodeEntity != null) {
      newCalculatedPlayerIdx =
          reorderedPlaylist.indexOf(originalPlayingEpisodeEntity);
      if (newCalculatedPlayerIdx == -1) {
        newCalculatedPlayerIdx = null;
      }
    } else {
      newCalculatedPlayerIdx = null;
    }

    emit(state.copyWith(
      currentPlaylist: reorderedPlaylist,
      currentIndex: newCalculatedPlayerIdx,
    ));
  }

  // Needed only when removing episodes from the user playlist (episodes from podcast episode lists cannot be removed)
  Future<void> updateCurrentPlaylistAfterRemovingEpisode({
    required int indexToRemove,
  }) async {
    final List<EpisodeEntity> originalPlaylist = state.currentPlaylist;
    final int? originalPlaybackIndex = state.currentIndex;
    final bool isAutoplayEnabled = state.isAutoplayEnabled;

    // 1. Out of bounds check
    if (indexToRemove < 0 || indexToRemove >= originalPlaylist.length) {
      return;
    }

    // 2. Create the new playlist and remove the episode from it
    final List<EpisodeEntity> updatedPlaylist = List.from(originalPlaylist);
    final EpisodeEntity removedEpisode = updatedPlaylist.removeAt(indexToRemove);

    // 3. Define the new state
    if (updatedPlaylist.isEmpty) {
      await getIt<MyAudioHandler>().stop();
      resetPlayback();
      return;
    }

    int? newPlaybackIndex;
    if (originalPlaybackIndex != null) {
      // An episode is currently playing
      if (indexToRemove == originalPlaybackIndex) {
        // Episode to remove is the current episode

        // save the position of the episode to remove
        _saveEpisodePosition(removedEpisode);
        if (isAutoplayEnabled) {
          // Autoplay is enabled: stop the player, emit the next episode, next index and updated playlist
          newPlaybackIndex = originalPlaybackIndex - 1;
          emit(state.copyWith(
            episode: updatedPlaylist[newPlaybackIndex],
            currentPlaylist: updatedPlaylist,
            currentIndex: newPlaybackIndex,
          ));
          // Play the next episode.
          getIt<MyAudioHandler>().playNext(autoplayEnabled: isAutoplayEnabled);
          return;
        } else {
          // Autoplay is disabled: stop the player and reset the playback
          await getIt<MyAudioHandler>().player.stop();
          newPlaybackIndex = null;
          resetPlayback();
          return;
        }
      }

      // Episode to remove is not the current episode.
      // Find it first:
      newPlaybackIndex = updatedPlaylist.indexWhere((episode) =>
          episode.id == originalPlaylist[originalPlaybackIndex].id);

      if (newPlaybackIndex == -1) {
        // no episode found in the new playlist: stop the player and reset the playback
        newPlaybackIndex = null;
        await getIt<MyAudioHandler>().stop();
        resetPlayback();
        return;
      } else {
        newPlaybackIndex = newPlaybackIndex;
        emit(state.copyWith(
          currentPlaylist: updatedPlaylist,
          currentIndex: newPlaybackIndex,
        ));
      }
    } else {
      // No current playback: just update the playlist
      emit(state.copyWith(
        currentPlaylist: updatedPlaylist,
      ));
      return;
    }
  }
}
