part of 'podcasts_bloc.dart';

@immutable
sealed class PodcastsState {}

final class PodcastsInitial extends PodcastsState {}

final class SubscribedPodcastsLoadingState extends PodcastsState {}

final class SubscribedPodcastsLoadedState extends PodcastsState {
  /// TODO: implement entity for subscribed podcasts
  final List subscribedPodcasts;

  SubscribedPodcastsLoadedState({
    required this.subscribedPodcasts,
  });
}

final class PodcastsFetchingState extends PodcastsState {}

final class PodcastsReceivedState extends PodcastsState {
  final String keyword;
  final List<PodcastEntity> podcasts;

  PodcastsReceivedState({
    required this.keyword,
    required this.podcasts,
  });
}
