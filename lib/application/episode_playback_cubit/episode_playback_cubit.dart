import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/helpers/player/audiohandler.dart';
import 'package:podcast/injection.dart';

import '../../core/globals.dart';
import '../../domain/entities/podcast_entity.dart';

part 'episode_playback_state.dart';

class EpisodePlaybackCubit extends Cubit<EpisodePlaybackState> {
  EpisodePlaybackCubit() : super(const EpisodePlaybackState());

  void setPlaybackEpisode({
    PodcastEntity? podcast,
    EpisodeEntity? episodeToPlay,
    List<EpisodeEntity>? playlist,
    int? startIndexInPlaylist,
  }) {
    emit(state.copyWith(
      podcast: podcast,
      episode: episodeToPlay,
      episodes: playlist,
      currentIndexInPlaylist: startIndexInPlaylist,
    ));
  }

  void resetPlayback() {
    emit(const EpisodePlaybackState());
  }

  Future<bool> playNextInCubit() async {
    final currentState = state;
    // Save position of previous episode before changing to new one
    if (currentState.episode != null) {
      final previousPlaybackEpisode = currentState.episode;
      previousPlaybackEpisode!.position =
          getIt<MyAudioHandler>().player.position.inSeconds;
      episodeBox.put(previousPlaybackEpisode);
    }

    if ((currentState.episodes != null && currentState.episodes!.isEmpty) ||
        currentState.currentIndexInPlaylist == -1) {
      return false;
    }

    final nextIndex = currentState.currentIndexInPlaylist + 1;
    if (nextIndex < currentState.episodes!.length) {
      final nextEpisode = currentState.episodes![nextIndex];

      emit(currentState.copyWith(
        episode: nextEpisode,
        currentIndexInPlaylist: nextIndex,
      ));
      return true;
      // true: playback is handled by audioHandler that will also update the notification
    } else {
      // End of playlist reached
      return false;
    }
  }

  Future<bool> playPreviousInCubit() async {
    final currentState = state;

    if (currentState.episode != null) {
      final previousPlaybackEpisode = currentState.episode;
      previousPlaybackEpisode!.position =
          getIt<MyAudioHandler>().player.position.inSeconds;
      episodeBox.put(previousPlaybackEpisode);
    }

    if ((currentState.episodes != null && currentState.episodes!.isEmpty) ||
        currentState.currentIndexInPlaylist == -1) {
      return false;
    }

    final prevIndex = currentState.currentIndexInPlaylist - 1;
    if (prevIndex >= 0) {
      final prevEpisode = currentState.episodes![prevIndex];
      emit(currentState.copyWith(
        episode: prevEpisode,
        currentIndexInPlaylist: prevIndex,
      ));
      return true;
    } else {
      return false;
    }
  }
}
