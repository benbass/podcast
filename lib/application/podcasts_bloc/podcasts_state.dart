part of 'podcasts_bloc.dart';

@immutable
sealed class PodcastsState {}

final class PodcastsInitial extends PodcastsState {}

final class PodcastsFetchingState extends PodcastsState {}

final class PodcastsFillingWithEpisodesState extends PodcastsState {}

final class PodcastsReceivedState extends PodcastsState {
  final String keyword;
  final List<PodcastEntity> podcasts;
  final List<PodcastEntity> subscribedPodcasts;
  PodcastsReceivedState({
    required this.keyword,
    required this.podcasts,
    required this.subscribedPodcasts,
  });
}

final class PodcastFilledWithEpisodesState extends PodcastsState {
  final String keyword;
  final List<PodcastEntity> podcasts;
  final List<PodcastEntity> subscribedPodcasts;
  final PodcastEntity podcast;
  PodcastFilledWithEpisodesState({
    required this.keyword,
    required this.podcasts,
    required this.subscribedPodcasts,
    required this.podcast,
  });
}

final class PodcastIsSubscribedState extends PodcastsState {
  final PodcastEntity podcast;
  final List<PodcastEntity> subscribedPodcasts;
  PodcastIsSubscribedState({
    required this.podcast,
    required this.subscribedPodcasts,
  });
}

final class PodcastIsUnsubscribedState extends PodcastsState {
  final PodcastEntity podcast;
  final List<PodcastEntity> subscribedPodcasts;
  PodcastIsUnsubscribedState({
    required this.podcast,
    required this.subscribedPodcasts,
  });
}

final class FetchingSubscribedPodcastsState extends PodcastsState {}

final class GotSubscribedPodcastsState extends PodcastsState {
  final List<PodcastEntity> podcasts;
  GotSubscribedPodcastsState({
    required this.podcasts,
});
}
