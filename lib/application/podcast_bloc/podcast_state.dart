part of 'podcast_bloc.dart';

enum PodcastStatus { initial, loading, success, failure }

@immutable
class PodcastState extends Equatable {
  final PodcastStatus status;
  final List<PodcastEntity> subscribedPodcasts;
  final List<PodcastEntity> queryResultPodcasts;
  final PodcastEntity currentPodcast;
  final List<EpisodeEntity> episodes;
  final bool areReadEpisodesVisible;
  final String keyword;
  final bool refreshEpisodes;
  const PodcastState({
    required this.status,
    required this.subscribedPodcasts,
    required this.queryResultPodcasts,
    required this.currentPodcast,
    required this.episodes,
    required this.areReadEpisodesVisible,
    required this.keyword,
    required this.refreshEpisodes,
  });

  PodcastState.initial()
      : status = PodcastStatus.initial,
        subscribedPodcasts = const <PodcastEntity>[],
        queryResultPodcasts = const <PodcastEntity>[],
        currentPodcast = PodcastEntity.emptyPodcast(),
        episodes = const <EpisodeEntity>[],
        areReadEpisodesVisible = false,
        keyword = '',
        refreshEpisodes = false;

  PodcastState copyWith({
    PodcastStatus? status,
    List<PodcastEntity>? subscribedPodcasts,
    List<PodcastEntity>? queryResultPodcasts,
    PodcastEntity? currentPodcast,
    List<EpisodeEntity>? episodes,
    bool? areReadEpisodesVisible,
    String? keyword,
    bool? refreshEpisodes,
  }) {
    return PodcastState(
      status: status ?? this.status,
      subscribedPodcasts: subscribedPodcasts ?? this.subscribedPodcasts,
      queryResultPodcasts: queryResultPodcasts ?? this.queryResultPodcasts,
      currentPodcast: currentPodcast ?? this.currentPodcast,
      episodes: episodes ?? this.episodes,
      areReadEpisodesVisible:
          areReadEpisodesVisible ?? this.areReadEpisodesVisible,
      keyword: keyword ?? this.keyword,
      refreshEpisodes: refreshEpisodes ?? this.refreshEpisodes,
    );
  }

  @override
  List<Object> get props => [
        status,
        subscribedPodcasts,
        queryResultPodcasts,
        currentPodcast,
        episodes,
        areReadEpisodesVisible,
        keyword,
        refreshEpisodes,
      ];
}
