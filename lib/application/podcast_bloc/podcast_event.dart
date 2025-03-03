part of 'podcast_bloc.dart';

@immutable
sealed class PodcastEvent {}

final class SubscribedPodcastsLoadingEvent extends PodcastEvent {}

final class SubscribedPodcastsLoadedEvent extends PodcastEvent {}

final class SearchPodcastsByKeywordProcessingEvent extends PodcastEvent {
  final String keyword;
  SearchPodcastsByKeywordProcessingEvent({
    required this.keyword,
  });
}

final class SearchPodcastsByKeywordSuccessEvent extends PodcastEvent {}

final class FetchEpisodesForPodcastProcessingEvent extends PodcastEvent {
  final PodcastEntity podcast;
  FetchEpisodesForPodcastProcessingEvent({
    required this.podcast,
  });
}

final class FetchEpisodesForPodcastSuccessEvent extends PodcastEvent {}

final class RefreshPodcastEpisodesProcessingEvent extends PodcastEvent {}

final class PodcastTappedEvent extends PodcastEvent {
  final PodcastEntity podcast;
  PodcastTappedEvent({
    required this.podcast,
  });
}

final class SubscribeToPodcastEvent extends PodcastEvent {}

final class UnSubscribeFromPodcastEvent extends PodcastEvent {}

final class PodcastsQueryResultUpdateEvent extends PodcastEvent {}
