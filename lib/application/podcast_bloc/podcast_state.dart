part of 'podcast_bloc.dart';

class PodcastState {
  final PodcastEntity? podcast;
  final List<PodcastEntity> subscribedPodcasts;
  final List<PodcastEntity> podcastsQueryResult;
  final String? keyword;
  final bool loading;
  final String? message;
  final bool areReadEpisodesVisible;

  const PodcastState({
    required this.podcast,
    required this.subscribedPodcasts,
    required this.podcastsQueryResult,
    required this.keyword,
    required this.loading,
    required this.message,
    required this.areReadEpisodesVisible,
  });

  factory PodcastState.initial() => const PodcastState(
      podcast: null,
      subscribedPodcasts: [],
      podcastsQueryResult: [],
      keyword: null,
      loading: false,
      message: null,
      areReadEpisodesVisible: false,
  );

  factory PodcastState.error({required String message}) => PodcastState(
        podcast: null,
        subscribedPodcasts: const [],
        podcastsQueryResult: const [],
        keyword: null,
        loading: false,
        message: message,
        areReadEpisodesVisible: false,
      );

  PodcastState copyWith({
    List<PodcastEntity>? subscribedPodcasts,
    List<PodcastEntity>? podcastsQueryResult,
    PodcastEntity? podcast,
    String? keyword,
    bool? loading,
    String? message,
    bool? areReadEpisodesVisible,
  }) {
    return PodcastState(
      podcast: podcast ?? this.podcast,
      subscribedPodcasts: subscribedPodcasts ?? this.subscribedPodcasts,
      podcastsQueryResult: podcastsQueryResult ?? this.podcastsQueryResult,
      keyword: keyword ?? this.keyword,
      loading: loading ?? this.loading,
      message: message ?? this.message,
      areReadEpisodesVisible: areReadEpisodesVisible ?? this.areReadEpisodesVisible,
    );
  }
}
