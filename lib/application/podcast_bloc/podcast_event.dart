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

class GetUnreadEpisodesByFeedIdEvent extends PodcastEvent {
  final int feedId;
  const GetUnreadEpisodesByFeedIdEvent({
    required this.feedId,
  });
  @override
  List<Object> get props => [feedId];
}

final class ToggleUnreadEpisodesVisibilityEvent extends PodcastEvent {
  final bool areReadEpisodesVisible;
  const ToggleUnreadEpisodesVisibilityEvent({
    required this.areReadEpisodesVisible,
  });
  @override
  List<Object> get props => [areReadEpisodesVisible];
}

/// REMOTE
// Podcast Remote
final class GetRemotePodcastsByKeywordEvent extends PodcastEvent {
  final String keyword;
  const GetRemotePodcastsByKeywordEvent({
    required this.keyword,
  });
  @override
  List<Object> get props => [keyword];
}

final class UpdateQueryEvent extends PodcastEvent {
  final int feedId;

  const UpdateQueryEvent({
    required this.feedId,
  });
  @override
  List<Object> get props => [feedId];
}

final class RefreshEpisodesByFeedIdEvent extends PodcastEvent {
  final int feedId;
  const RefreshEpisodesByFeedIdEvent({
    required this.feedId,
  });
  @override
  List<Object> get props => [feedId];
}


/// LOCAL and REMOTE
// Episodes Local or remote
class GetEpisodesByFeedIdEvent extends PodcastEvent {
  final int feedId;
  const GetEpisodesByFeedIdEvent({
    required this.feedId,
  });
  @override
  List<Object> get props => [feedId];
}


/// None
final class PodcastTappedEvent extends PodcastEvent {
  final PodcastEntity podcast;
  const PodcastTappedEvent({
    required this.podcast,
  });
  @override
  List<Object> get props => [podcast];
}
