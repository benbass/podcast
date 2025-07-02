part of 'playback_cubit.dart';

enum PlaybackStatus { playing, paused, stopped, loading, error }

class PlaybackState extends Equatable {
  final EpisodeEntity? episode;
  final List<EpisodeEntity> currentPlaylist;
  final int? currentIndex;
  final bool isAutoplayEnabled;
  final bool isUserPlaylist;
  final PlaybackStatus playbackStatus;

  const PlaybackState({
    this.episode,
    this.currentPlaylist = const <EpisodeEntity>[],
    this.currentIndex,
    this.isAutoplayEnabled = false,
    this.isUserPlaylist = false,
    this.playbackStatus = PlaybackStatus.stopped,
  });

  PlaybackState copyWith({
    EpisodeEntity? episode,
    List<EpisodeEntity>? currentPlaylist,
    int? currentIndex,
    bool? isAutoplayEnabled,
    bool? isUserPlaylist,
    PlaybackStatus? playbackStatus,
  }) {
    return PlaybackState(
      episode: episode ?? this.episode,
      currentPlaylist: currentPlaylist ?? this.currentPlaylist,
      currentIndex: currentIndex ?? this.currentIndex,
      isAutoplayEnabled: isAutoplayEnabled ?? this.isAutoplayEnabled,
      isUserPlaylist: isUserPlaylist ?? this.isUserPlaylist,
      playbackStatus: playbackStatus ?? this.playbackStatus,
    );
  }

  PlaybackState clearEpisode(){
    return PlaybackState(
      episode: null,
      currentIndex: null,
      playbackStatus: PlaybackStatus.stopped,
    );
  }

  @override
  List<Object?> get props => [
        episode,
        currentPlaylist,
        currentIndex,
        isAutoplayEnabled,
        isUserPlaylist,
        playbackStatus,
      ];
}
