part of 'podcast_bloc.dart';

@immutable
sealed class PodcastEvent extends Equatable {
  const PodcastEvent();
  @override
  List<Object> get props => [];
}

/// LOCAL
// Podcast Local
final class LoadSubscribedPodcastsEvent extends PodcastEvent {}

final class SubscribeToPodcastEvent extends PodcastEvent {
  final PodcastEntity podcast;
  const SubscribeToPodcastEvent({
    required this.podcast,
  });
  @override
  List<Object> get props => [podcast];
}

final class UnSubscribeFromPodcastEvent extends PodcastEvent {
  final int id;
  const UnSubscribeFromPodcastEvent({
    required this.id,
  });
  @override
  List<Object> get props => [id];
}

/// REMOTE
// Podcast Remote

final class FetchTrendingPodcastsEvent extends PodcastEvent {}

final class GetRemotePodcastsByKeywordEvent extends PodcastEvent {
  final String keyword;
  const GetRemotePodcastsByKeywordEvent({
    required this.keyword,
  });
  @override
  List<Object> get props => [keyword];
}

final class UpdateQueryEvent extends PodcastEvent {}


/// None
final class PodcastSelectedEvent extends PodcastEvent {
  final PodcastEntity podcast;
  const PodcastSelectedEvent({
    required this.podcast,
  });
  @override
  List<Object> get props => [podcast];
}

final class ToggleStateToSuccessAfterFailureEvent extends PodcastEvent {}
