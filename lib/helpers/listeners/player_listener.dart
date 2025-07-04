import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcast/core/globals.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/main.dart';
import '../../application/user_playlist/user_playlist_cubit/user_playlist_cubit.dart';
import '../../injection.dart';
import '../../presentation/audioplayer_overlays/audioplayer_overlays.dart';
import '../player/audiohandler.dart';

/*
ProcessingState.idle: player is idle and didn't load any audio file.
ProcessingState.loading: player is loading audio file.
ProcessingState.buffering: player buffers audio file.
ProcessingState.ready: player ready for playback. >>> Use this for pause state
player.playing: player ia playing audio file.
ProcessingState.completed: playback is completed
 */
typedef ResetPlaybackEpisodeCallback = void Function();

class PlayerStatesListener {
  EpisodeEntity? Function()? _getCurrentEpisode;
  bool? Function()? _getAutoplayStatus;
  final AudioPlayer player = getIt<MyAudioHandler>().player;
  StreamSubscription<PlayerState>? _audioPlayerStateSubscription;

  PlayerStatesListener() {
    _audioPlayerStateSubscription =
        player.playerStateStream.listen(_handlePlayerStateChanged);
  }

  void setGetCurrentEpisode(EpisodeEntity? Function() getter) {
    _getCurrentEpisode = getter;
  }

  void setGetAutoplayStatus(bool? Function() getter) {
    _getAutoplayStatus = getter;
  }

  void _handlePlayerStateChanged(PlayerState playerState) async {
    final context = MyApp.navigatorKey.currentContext;
    final bool? autoplayStatus = _getAutoplayStatus?.call();
    final EpisodeEntity? currentEpisode = _getCurrentEpisode?.call();
    if (currentEpisode == null) return;
    switch (playerState.processingState) {
      case ProcessingState.completed:
        await _updateEpisodePosition(
            episode: currentEpisode, position: 0, isCompleted: true);
        if (context!.mounted) {
          context.read<UserPlaylistCubit>().loadPlaylist();
        }
        if (autoplayStatus == true) {
          await getIt<MyAudioHandler>()
              .playNext(autoplayEnabled: autoplayStatus);
          if (context.mounted &&
              autoplayStatus == true &&
              overlayEntry == null) {
            showOverlayPlayerMin(context);
          }
        } else {
          getIt<MyAudioHandler>().stopOnCompleted();
        }
        break;
      case ProcessingState.ready:
        if (player.position.inSeconds > 0) {
          _updateEpisodePosition(
              episode: currentEpisode,
              position: player.position.inSeconds,
              isCompleted: false);
        }
        break;
      default:
        break;
    }
  }

  Future<void> _updateEpisodePosition({
    required EpisodeEntity episode,
    required int position,
    required bool isCompleted,
  }) async {
    episode.position = position;
    if (isCompleted) {
      episode.completed = true;
      episode.read = true;
    }

    episodeBox.put(episode);
  }

  void dispose() {
    _audioPlayerStateSubscription?.cancel();
    player.dispose();
  }
}
