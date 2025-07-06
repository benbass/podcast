import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../application/playback/playback_cubit/playback_cubit.dart';
import '../../core/globals.dart';
import '../../domain/entities/episode_entity.dart';
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

  // Start audio playback.
  Future<void> play() async {
    final context = MyApp.navigatorKey.currentContext;
    final episode = context!.read<PlaybackCubit>().state.episode;
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
    final currentEpisode = context!.read<PlaybackCubit>().state.episode;
    currentEpisode!.position =
        getIt<MyAudioHandler>().player.position.inSeconds;
    episodeBox.put(currentEpisode);
    UtilitiesNotifications.cancelNotificationPlayback();
    context.read<PlaybackCubit>().resetPlayback();

    await player.stop();
  }

  Future<void> stopOnCompleted() async {
    final context = MyApp.navigatorKey.currentContext;
    context!.read<PlaybackCubit>().resetPlayback();

    await player.stop();

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
  void handlePlayPause() async {
    if (player.playing) {
      pause();
    } else {
      await player.play();
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

  Future<bool> playNext({bool? autoplayEnabled}) async {
    bool playbackCubitIsReady = false;
    final context = MyApp.navigatorKey.currentContext;
    if (context!.mounted) {
      playbackCubitIsReady = await BlocProvider.of<PlaybackCubit>(context)
          .onPlayNext(autoplayEnabled);
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
      playbackCubitIsReady =
          await BlocProvider.of<PlaybackCubit>(context).onPlayPrevious();
    }
    if (playbackCubitIsReady) {
      await play();
    }
    return playbackCubitIsReady;
  }

  // Actions from cards
  // play
  void playEpisodeFromCard(
    BuildContext context,
    int index,
    EpisodeEntity episode,
    List<EpisodeEntity> episodes,
    bool autoplayEnabled,
  ) async {
    if (context.read<PlaybackCubit>().state.episode != null) {
      final previousEpisode = context.read<PlaybackCubit>().state.episode;
      previousEpisode!.position = player.position.inSeconds;
      episodeBox.put(previousEpisode);
    }
    await context.read<PlaybackCubit>().onPlay(
          origin: globalPlaylistId.toString(),
          episode: episode,
          playlist: episodes,
          isAutoplayEnabled: autoplayEnabled,
          currentIndex: index,
          isUserPlaylist: true,
        );

    await play();
    if (context.mounted && overlayEntry == null) {
      showOverlayPlayerMin(context);
    }
  }

  // Play/Pause
  void handlePlayPauseFromCard(BuildContext context) {
    handlePlayPause();
    context.read<PlaybackCubit>().onPlayPause();
  }

  //
  void dispose() {
    player.dispose();
  }
}
