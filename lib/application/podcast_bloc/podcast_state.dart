part of 'podcast_bloc.dart';

enum PodcastStatus { initial, loading, success, failure }

@immutable
class PodcastState extends Equatable {
  final PodcastStatus status;
  final List<PodcastEntity> subscribedPodcasts;
  final List<PodcastEntity> queryResultPodcasts;
  final List<PodcastEntity> trendingPodcasts;
  final PodcastEntity currentPodcast;

  const PodcastState({
    required this.status,
    required this.subscribedPodcasts,
    required this.queryResultPodcasts,
    required this.trendingPodcasts,
    required this.currentPodcast,
  });

  PodcastState.initial()
      : status = PodcastStatus.initial,
        subscribedPodcasts = const <PodcastEntity>[],
        queryResultPodcasts = const <PodcastEntity>[],
        trendingPodcasts = const <PodcastEntity>[],
        currentPodcast = PodcastEntity.emptyPodcast();

  PodcastState copyWith({
    PodcastStatus? status,
    List<PodcastEntity>? subscribedPodcasts,
    List<PodcastEntity>? queryResultPodcasts,
    List<PodcastEntity>? trendingPodcasts,
    PodcastEntity? currentPodcast,
  }) {
    return PodcastState(
      status: status ?? this.status,
      subscribedPodcasts: subscribedPodcasts ?? this.subscribedPodcasts,
      queryResultPodcasts: queryResultPodcasts ?? this.queryResultPodcasts,
      trendingPodcasts: trendingPodcasts ?? this.trendingPodcasts,
      currentPodcast: currentPodcast ?? this.currentPodcast,
    );
  }

  @override
  List<Object> get props => [
        status,
        subscribedPodcasts,
        queryResultPodcasts,
        trendingPodcasts,
        currentPodcast,
      ];
}
