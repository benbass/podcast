part of 'podcast_bloc.dart';

enum PodcastStatus { initial, loading, success, failure }
enum EpisodesFilterStatus { all, hideRead, unfinished, favorites, downloaded }

@immutable
class PodcastState extends Equatable {
  final PodcastStatus status;
  final List<PodcastEntity> subscribedPodcasts;
  final List<PodcastEntity> queryResultPodcasts;
  final List<PodcastEntity> trendingPodcasts;
  final PodcastEntity currentPodcast;
  final EpisodesFilterStatus episodesFilterStatus;
  const PodcastState({
    required this.status,
    required this.subscribedPodcasts,
    required this.queryResultPodcasts,
    required this.trendingPodcasts,
    required this.currentPodcast,
    required this.episodesFilterStatus,
  });

  PodcastState.initial()
      : status = PodcastStatus.initial,
        subscribedPodcasts = const <PodcastEntity>[],
        queryResultPodcasts = const <PodcastEntity>[],
        trendingPodcasts = const <PodcastEntity>[],
        currentPodcast = PodcastEntity.emptyPodcast(),
        episodesFilterStatus = EpisodesFilterStatus.hideRead;

  PodcastState copyWith({
    PodcastStatus? status,
    List<PodcastEntity>? subscribedPodcasts,
    List<PodcastEntity>? queryResultPodcasts,
    List<PodcastEntity>? trendingPodcasts,
    PodcastEntity? currentPodcast,
    EpisodesFilterStatus? episodesFilterStatus,
  }) {
    return PodcastState(
      status: status ?? this.status,
      subscribedPodcasts: subscribedPodcasts ?? this.subscribedPodcasts,
      queryResultPodcasts: queryResultPodcasts ?? this.queryResultPodcasts,
      trendingPodcasts: trendingPodcasts ?? this.trendingPodcasts,
      currentPodcast: currentPodcast ?? this.currentPodcast,
      episodesFilterStatus: episodesFilterStatus ?? this.episodesFilterStatus,
    );
  }

  @override
  List<Object> get props => [
        status,
        subscribedPodcasts,
        queryResultPodcasts,
        trendingPodcasts,
        currentPodcast,
        episodesFilterStatus,
      ];
}
