import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../core/globals.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/podcast_entity.dart';
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

  Future<void> handlePlayButtonPressed(BuildContext context,
      EpisodeEntity episode, PodcastEntity podcast) async {
    final currentPosition = player.position.inSeconds;
    final String connectionType =
        await getIt<ConnectivityManager>().getConnectionTypeAsString();
    String filePath = episode.filePath ?? episode.enclosureUrl;
    if (connectionType == 'none' && filePath == episode.enclosureUrl) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) =>
              const FailureDialog(message: "No internet connection!"),
        );
      }
    } else {
      removeOverlay();
      // source error?
      try {
        if (context.mounted) {
          // Save position of previous episode before changing to new one
          if (BlocProvider.of<EpisodePlaybackCubit>(context).state != null) {
            final previousEpisode =
                BlocProvider.of<EpisodePlaybackCubit>(context)
                    .state!
                    .values
                    .first;
            previousEpisode.position = currentPosition;
            episodeBox.put(previousEpisode);
          }
        }

        await player.setUrl(filePath);
        play();
        if (episode.position > 0) {
          player.seek(Duration(seconds: episode.position));
        }

        if (context.mounted) {
          BlocProvider.of<EpisodePlaybackCubit>(context)
              .setPlaybackEpisode({podcast: episode});
          UtilitiesNotifications.createNotificationPlayback(
              context, false, episode.position);
        }
      } on PlayerException {
        if (context.mounted) {
          showOverlayError(
              context, "Error: No valid file exists under the requested url.");
        }
      }
    }
  }

  // Start audio playback.
  Future<void> play() async {
    await player.play();
    final context = MyApp.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      UtilitiesNotifications.createNotificationPlayback(
          context, false, player.position.inSeconds);
    }
  }

  // Stop audio playback.
  Future<void> stop() async {
    await player.stop();
    UtilitiesNotifications.cancelNotificationPlayback();

    final context = MyApp.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      removeOverlay();
    }
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
    final context = MyApp.navigatorKey.currentContext;
    bool isPaused = false;
    if (player.playing) {
      player.pause();
      isPaused = true;
    } else {
      player.play();
      isPaused = false;
    }
    if (context != null && context.mounted) {
      UtilitiesNotifications.createNotificationPlayback(
          context, isPaused, player.position.inSeconds);
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

  void dispose() {
    player.dispose();
  }
}
