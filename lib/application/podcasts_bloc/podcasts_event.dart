part of 'podcasts_bloc.dart';

@immutable
sealed class PodcastsEvent {}

final class FetchSubscribedPodcastsEvent extends PodcastsEvent {}

class FetchPodcastsEvent extends PodcastsEvent {
  final String keyword;
  FetchPodcastsEvent({
    required this.keyword,
  });
}

class PodcastsFetchSuccessEvent extends PodcastsEvent {
  final String keyword;
  final List<PodcastEntity> podcastsQueryResult;
  PodcastsFetchSuccessEvent({
    required this.keyword,
    required this.podcastsQueryResult,
  });
}

class FillPodcastWithEpisodesEvent extends PodcastsEvent {
  final PodcastEntity podcast;
  FillPodcastWithEpisodesEvent({
    required this.podcast,
  });
}

class FillPodcastWithEpisodesSuccessEvent extends PodcastsEvent {
  final PodcastEntity podcast;
  FillPodcastWithEpisodesSuccessEvent({
    required this.podcast,
  });
}

final class SubscribeToPodcastEvent extends PodcastsEvent {
  final PodcastEntity podcast;
  SubscribeToPodcastEvent({
    required this.podcast,
  });
}

final class UnsubscribeFromPodcastEvent extends PodcastsEvent {
  final PodcastEntity podcast;
  UnsubscribeFromPodcastEvent({
    required this.podcast,
  });
}
