import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../core/globals.dart';
import '../../injection.dart';
import '../../main.dart';
import '../../presentation/audioplayer_overlays/audioplayer_overlays.dart';
import '../../presentation/custom_widgets/dialogs/failure_dialog.dart';
import '../core/connectivity_manager.dart';
import '../notifications/utilities_notifications.dart';

/*
ProcessingState.idle: player is idle and didn't load any audio file.
ProcessingState.loading: player is loading audio file.
ProcessingState.buffering: player buffers audio file.
ProcessingState.ready: player ready for playback. >>> Use this for pause state
player.playing: player ia playing audio file.
ProcessingState.completed: playback is completed
 */

class MyAudioHandler {
  final player = AudioPlayer(); // Instance of the JustAudio player.

/*
  MyAudioHandler() {
    // Listen for player state changes (e.g., playing, paused, buffering)
    player.playerStateStream.listen((playerState) {
      final processingState = playerState.processingState;

      if( processingState == ProcessingState.completed){
        //player.seek(Duration.zero);
        //player.pause();
        stop();
        removeOverlay();
        // Here we cannot call any method that requires a context!
      }
    });
  }
*/

  // Start audio playback.
  Future<void> play() async {
    final context = MyApp.navigatorKey.currentContext;
    final episode = context!.read<EpisodePlaybackCubit>().state.episode;
    final String connectionType =
        await getIt<ConnectivityManager>().getConnectionTypeAsString();
    String filePath = episode!.filePath ?? episode.enclosureUrl;
    if (connectionType == 'none' && filePath == episode.enclosureUrl) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) =>
              const FailureDialog(message: "No internet connection!"),
        );
      }
    } else {
      removeOverlayPlayerMin();
      try {
        await player.setUrl(filePath);

        if (episode.position > 0) {
          Duration position = Duration(seconds: episode.position);
          await player.seek(position);
        }
        if (context.mounted) {
          UtilitiesNotifications.createNotificationPlayback(
              context, false, player.position.inSeconds);
        }
        await player.play();
      } on PlayerException {
        if (context.mounted) {
          showOverlayError(
              context, "Error: No valid file exists under the requested url.");
        }
      }
    }
  }

  // Stop audio playback.
  Future<void> stop() async {
    final context = MyApp.navigatorKey.currentContext;
    // Save the current position to the episode
    final currentEpisode = context!.read<EpisodePlaybackCubit>().state.episode;
    currentEpisode!.position =
        getIt<MyAudioHandler>().player.position.inSeconds;
    episodeBox.put(currentEpisode);

    await player.stop();

    if (context.mounted) {
      BlocProvider.of<EpisodePlaybackCubit>(context).resetPlayback();
    }

    removeOverlayPlayerMin();

    UtilitiesNotifications.cancelNotificationPlayback();
  }

  // Pause audio playback.
  Future<void> pause() async {
    await player.pause();
    final context = MyApp.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      UtilitiesNotifications.createNotificationPlayback(
          context, true, player.position.inSeconds);
    }
  }

  // Handling Play and Pause
  void handlePlayPause() {
    if (player.playing) {
      pause();
    } else {
      player.play();
      final context = MyApp.navigatorKey.currentContext;
      if (context != null && context.mounted) {
        UtilitiesNotifications.createNotificationPlayback(
            context, false, player.position.inSeconds);
      }
    }
  }

  final Duration _seekValue = const Duration(seconds: 30);
  // Seek +
  void seekForward() {
    Duration position = player.position;
    Duration newPosition = position + _seekValue;
    if (newPosition > player.duration!) {
      newPosition = player.duration!;
    }
    player.seek(newPosition);
  }

// Seek -
  void seekBackward() {
    Duration position = player.position;
    Duration newPosition = position - _seekValue;
    if (newPosition < const Duration(seconds: 0)) {
      newPosition = const Duration(seconds: 0);
    }
    player.seek(newPosition);
  }

  Future<bool> playNext() async {
    bool playbackCubitIsReady = false;
    final context = MyApp.navigatorKey.currentContext;
    if (context!.mounted) {
      playbackCubitIsReady = await BlocProvider.of<EpisodePlaybackCubit>(context)
          .playNextInCubit();
    }
    if (playbackCubitIsReady) {
      await play();
    }
    return playbackCubitIsReady;
  }

  Future<bool> playPrevious() async {
    bool playbackCubitIsReady = false;
    final context = MyApp.navigatorKey.currentContext;

    if (context!.mounted) {
      playbackCubitIsReady = await BlocProvider.of<EpisodePlaybackCubit>(context)
          .playPreviousInCubit();
    }
    if (playbackCubitIsReady) {
      await play();
    }
    return playbackCubitIsReady;
  }

  void dispose() {
    player.dispose();
  }
}
