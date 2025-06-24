part of 'episode_playback_cubit.dart';



class EpisodePlaybackState extends Equatable {
  final EpisodeEntity? episode;
  final List<EpisodeEntity>? episodes;
  final int currentIndexInPlaylist;

  const EpisodePlaybackState({
    this.episode,
    this.episodes,
    this.currentIndexInPlaylist = -1,
  });

  EpisodePlaybackState copyWith({
    PodcastEntity? podcast,
    EpisodeEntity? episode,
    List<EpisodeEntity>? episodes,
    int? currentIndexInPlaylist,
  }) {
    return EpisodePlaybackState(
      episode: episode ?? this.episode,
      episodes: episodes ?? this.episodes,
      currentIndexInPlaylist: currentIndexInPlaylist ?? this.currentIndexInPlaylist,
    );
  }


  @override
  List<Object?> get props => [episode, episodes, currentIndexInPlaylist];

}