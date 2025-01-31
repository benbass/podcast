part of 'podcasts_bloc.dart';

@immutable
sealed class PodcastsEvent {}

class FindPodcastsPressedEvent extends PodcastsEvent {
  final String keyword;
  FindPodcastsPressedEvent({
    required this.keyword,
  });
}

class FillPodcastWithEpisodesPressedEvent extends PodcastsEvent {
  final PodcastEntity podcast;
  FillPodcastWithEpisodesPressedEvent({
    required this.podcast,
  });
}

class PodcastsReceivedEvent extends PodcastsEvent {
  final String keyword;
  final List<PodcastEntity> podcasts;
  PodcastsReceivedEvent({
    required this.keyword,
    required this.podcasts,
  });
}

class PodcastFilledWithEpisodesEvent extends PodcastsEvent {
  final PodcastEntity podcast;
  PodcastFilledWithEpisodesEvent({
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

final class GetSubscribedPodcastsEvent extends PodcastsEvent {}
