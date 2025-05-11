import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../../main.dart';
import '../../presentation/audioplayer_overlays/audioplayer_overlays.dart';
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

  /// NOTIFICATION ///


  // Start audio playback.
  Future<void> play() async {
    await player.play();
    final context = MyApp.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      UtilitiesNotifications.createNotificationPlayback(context, false, player.position.inSeconds);
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
      UtilitiesNotifications.createNotificationPlayback(context, true, player.position.inSeconds);
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
      UtilitiesNotifications.createNotificationPlayback(context, isPaused, player.position.inSeconds);
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
