part of 'podcast_bloc.dart';

class PodcastState {
  final PodcastEntity? podcast;
  final List<PodcastEntity> subscribedPodcasts;
  final List<PodcastEntity> podcastsQueryResult;
  final bool loading;
  final String? message;

  const PodcastState({
    required this.podcast,
    required this.subscribedPodcasts,
    required this.podcastsQueryResult,
    required this.loading,
    required this.message,
  });

  factory PodcastState.initial() => const PodcastState(
        podcast: null,
        subscribedPodcasts: [],
        podcastsQueryResult: [],
        loading: false,
        message: null,
      );

  factory PodcastState.error({required String message}) => PodcastState(
        podcast: null,
        subscribedPodcasts: const [],
        podcastsQueryResult: const [],
        loading: false,
        message: message,
      );

  PodcastState copyWith({
    List<PodcastEntity>? subscribedPodcasts,
    List<PodcastEntity>? podcastsQueryResult,
    PodcastEntity? podcast,
    bool? loading,
    String? message,
  }) {
    return PodcastState(
      subscribedPodcasts: subscribedPodcasts ?? this.subscribedPodcasts,
      podcastsQueryResult: podcastsQueryResult ?? this.podcastsQueryResult,
      podcast: podcast ?? this.podcast,
      loading: loading ?? this.loading,
      message: message ?? this.message,
    );
  }
}
