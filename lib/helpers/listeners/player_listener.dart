import 'package:just_audio/just_audio.dart';
import 'package:podcast/core/globals.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
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
  ResetPlaybackEpisodeCallback? _resetPlaybackEpisode;
  final AudioPlayer player = getIt<MyAudioHandler>().player;

  PlayerStatesListener() {
    player.playerStateStream.listen(_handlePlayerStateChanged);
  }

  void setGetCurrentEpisode(
      EpisodeEntity? Function() getter) {
    _getCurrentEpisode = getter;
  }

  void setResetPlaybackEpisodeCallback(ResetPlaybackEpisodeCallback callback) {
    // the callback: context.read<EpisodePlaybackCubit>().setPlaybackEpisode(null);
    _resetPlaybackEpisode = callback;
  }

  _handlePlayerStateChanged(PlayerState playerState) {
    final EpisodeEntity? currentPlaybackEpisode =
        _getCurrentEpisode?.call();
    final EpisodeEntity? currentEpisode = currentPlaybackEpisode;
    if (currentEpisode == null) return;
    switch (playerState.processingState) {
      case ProcessingState.completed:
        _updateEpisodePosition(currentEpisode, 0, true);
        getIt<MyAudioHandler>().stop();
        removeOverlayPlayerMin();
        _resetPlaybackEpisode?.call();
        break;
      case ProcessingState.ready:
        if (player.position.inSeconds > 0) {
          _updateEpisodePosition(
              currentEpisode, player.position.inSeconds, false);
        }

        break;
      default:
        break;
    }
  }

  void _updateEpisodePosition(
    EpisodeEntity episode,
    int position,
    bool isCompleted,
  ) {
    episode.position = position;
    if (isCompleted) {
      episode.completed = true;
      episode.read = true;
    }

    episodeBox.put(episode);
  }
}
