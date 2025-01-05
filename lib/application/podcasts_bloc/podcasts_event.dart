part of 'podcasts_bloc.dart';

@immutable
sealed class PodcastsEvent {}

class SubscribedPodcastsLoadingEvent extends PodcastsEvent{}

class SubscribedPodcastsLoadedEvent extends PodcastsEvent{
  final List subscribedPodcasts;

  SubscribedPodcastsLoadedEvent({
    required this.subscribedPodcasts,
  });
}

class FindPodcastsPressedEvent extends PodcastsEvent {
  final String keyword;

  FindPodcastsPressedEvent({
    required this.keyword,
  });
}

class PodcastsReceivedEvent extends PodcastsEvent{
  final String keyword;
  final List<PodcastEntity> podcasts;

  PodcastsReceivedEvent({
    required this.keyword,
    required this.podcasts,
  });
}