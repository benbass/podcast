part of 'podcasts_bloc.dart';

@immutable
sealed class PodcastsState {}

final class PodcastsInitial extends PodcastsState {}

/// Subscribed podcasts states
final class FetchingSubscribedPodcastsState extends PodcastsState {}

final class SubscribedPodcastsFetchSuccessState extends PodcastsState {
  final List<PodcastEntity> podcasts;
  SubscribedPodcastsFetchSuccessState({
    required this.podcasts,
  });
}

final class SubscribedPodcastsFetchErrorState extends PodcastsState {
  final String message;
  SubscribedPodcastsFetchErrorState({
    required this.message,
  });
}

///

/// Fetching podcasts (for search) states
final class PodcastsFetchingState extends PodcastsState {}

final class PodcastsFetchSuccessState extends PodcastsState {
  final String keyword;
  final List<PodcastEntity> podcastsQueryResult;
  final List<PodcastEntity> subscribedPodcasts;
  PodcastsFetchSuccessState({
    required this.keyword,
    required this.podcastsQueryResult,
    required this.subscribedPodcasts,
  });
}

final class PodcastsFetchErrorState extends PodcastsState {
  final String message;
  PodcastsFetchErrorState({
    required this.message,
  });
}

///

/// Fill podcast with episodes states
final class PodcastFillingWithEpisodesState extends PodcastsState {}

final class PodcastFillWithEpisodesSuccessState extends PodcastsState {
  final String keyword;
  final List<PodcastEntity> podcastsQueryResult;
  final List<PodcastEntity> subscribedPodcasts;
  final PodcastEntity podcast;
  PodcastFillWithEpisodesSuccessState({
    required this.keyword,
    required this.podcastsQueryResult,
    required this.subscribedPodcasts,
    required this.podcast,
  });
}

final class PodcastFillWithEpisodesErrorState extends PodcastsState {
  final String message;
  PodcastFillWithEpisodesErrorState({
    required this.message,
  });
}

///

/// Podcast subscription states
final class PodcastChangeSubscriptionState extends PodcastsState {
  final PodcastEntity podcast;
  final List<PodcastEntity> podcastsQueryResult;
  final List<PodcastEntity> subscribedPodcasts;
  PodcastChangeSubscriptionState({
    required this.podcast,
    required this.podcastsQueryResult,
    required this.subscribedPodcasts,
  });
}

final class PodcastChangeSubscriptionErrorState extends PodcastsState {
  final String message;
  PodcastChangeSubscriptionErrorState({
    required this.message,
  });
}

///
