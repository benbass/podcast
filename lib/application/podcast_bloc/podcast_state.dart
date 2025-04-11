part of 'podcast_bloc.dart';

enum PodcastStatus { initial, loading, success, failure }

@immutable
class PodcastState extends Equatable {
  final PodcastStatus status;
  final List<PodcastEntity> subscribedPodcasts;
  final List<PodcastEntity> queryResultPodcasts;
  final List<PodcastEntity> trendingPodcasts;
  final PodcastEntity currentPodcast;
  final List<EpisodeEntity> episodes;
  final bool areReadEpisodesVisible;
  final String episodeToRefresh;
  const PodcastState({
    required this.status,
    required this.subscribedPodcasts,
    required this.queryResultPodcasts,
    required this.trendingPodcasts,
    required this.currentPodcast,
    required this.episodes,
    required this.areReadEpisodesVisible,
    required this.episodeToRefresh,
  });

  PodcastState.initial()
      : status = PodcastStatus.initial,
        subscribedPodcasts = const <PodcastEntity>[],
        queryResultPodcasts = const <PodcastEntity>[],
        trendingPodcasts = const <PodcastEntity>[],
        currentPodcast = PodcastEntity.emptyPodcast(),
        episodes = const <EpisodeEntity>[],
        areReadEpisodesVisible = false,
        episodeToRefresh = "";

  PodcastState copyWith({
    PodcastStatus? status,
    List<PodcastEntity>? subscribedPodcasts,
    List<PodcastEntity>? queryResultPodcasts,
    List<PodcastEntity>? trendingPodcasts,
    PodcastEntity? currentPodcast,
    List<EpisodeEntity>? episodes,
    bool? areReadEpisodesVisible,
    String? episodeToRefresh,
  }) {
    return PodcastState(
      status: status ?? this.status,
      subscribedPodcasts: subscribedPodcasts ?? this.subscribedPodcasts,
      queryResultPodcasts: queryResultPodcasts ?? this.queryResultPodcasts,
      trendingPodcasts: trendingPodcasts ?? this.trendingPodcasts,
      currentPodcast: currentPodcast ?? this.currentPodcast,
      episodes: episodes ?? this.episodes,
      areReadEpisodesVisible:
          areReadEpisodesVisible ?? this.areReadEpisodesVisible,
      episodeToRefresh: episodeToRefresh ?? this.episodeToRefresh,
    );
  }

  @override
  List<Object> get props => [
        status,
        subscribedPodcasts,
        queryResultPodcasts,
        trendingPodcasts,
        currentPodcast,
        episodes,
        areReadEpisodesVisible,
        episodeToRefresh,
      ];
}
