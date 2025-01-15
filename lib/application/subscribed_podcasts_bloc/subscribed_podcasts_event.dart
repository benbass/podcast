part of 'subscribed_podcasts_bloc.dart';

@immutable
sealed class SubscribedPodcastsEvent {}

class SubscribedPodcastsLoadingEvent extends SubscribedPodcastsEvent{}

class SubscribedPodcastsLoadedEvent extends SubscribedPodcastsEvent{
  final List<SubscribedPodcastEntity> subscribedPodcasts;

  SubscribedPodcastsLoadedEvent({
    required this.subscribedPodcasts,
  });
}
