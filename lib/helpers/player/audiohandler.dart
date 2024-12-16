import 'package:just_audio/just_audio.dart';
import 'package:podcast/helpers/notifications/create_notification.dart';

import '../../presentation/audioplayer_overlay.dart';


class MyAudioHandler {
  final player = AudioPlayer(); // Instance of the JustAudio player.

  MyAudioHandler() {
    // Listen for player state changes (e.g., playing, paused, buffering)
    player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      if( processingState == ProcessingState.completed){
        //player.seek(Duration.zero);
        //player.pause();
        stop();
        removeOverlay();
      }
    });
  }

  // Start audio playback.
  Future<void> play() async {
    await player.play();
    createNotification(false);
  }

  // Stop audio playback.
  Future<void> stop() async {
    await player.stop();
  }

  // Pause audio playback.
  Future<void> pause() async {
    await player.pause();
    createNotification(true);
  }

  // Handling Play and Pause
  void handlePlayPause() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  final Duration _seekValue = const Duration(seconds: 30);
  // Seek +
  void seekForward() {
    Duration position = player.position;
    Duration newPosition = position + _seekValue;
    if(newPosition > player.duration!){
      newPosition = player.duration!;
    }
    player.seek(newPosition);
  }

// Seek -
  void seekBackward() {
    Duration position = player.position;
    Duration newPosition = position - _seekValue;
    if (newPosition < const Duration(seconds: 0)){
      newPosition = const Duration(seconds: 0);
    }
    player.seek(newPosition);
  }
}
