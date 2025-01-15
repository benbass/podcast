part of 'subscribed_podcasts_bloc.dart';

@immutable
sealed class SubscribedPodcastsState {}

final class SubscribedPodcastsInitial extends SubscribedPodcastsState {}

final class SubscribedPodcastsLoadingState extends SubscribedPodcastsState {}

final class SubscribedPodcastsLoadedState extends SubscribedPodcastsState {
  final List<SubscribedPodcastEntity> subscribedPodcasts;

  SubscribedPodcastsLoadedState({
    required this.subscribedPodcasts,
  });
}
