part of 'episodes_bloc.dart';

abstract class EpisodesEvent extends Equatable {
  const EpisodesEvent();

  @override
  List<Object?> get props => [];
}

// Loads/observes episodes for a specific podcast
class LoadEpisodes extends EpisodesEvent {
  final int feedId; // Podcast-Feed id
  final bool isSubscribed;
  final PodcastFilterSettingsEntity? initialFilterSettings;

  const LoadEpisodes({
    required this.feedId,
    required this.isSubscribed,
    this.initialFilterSettings,
  });

  @override
  List<Object?> get props => [feedId, isSubscribed, initialFilterSettings];
}

// Internal event that is fired when the stream provides new episodes
class _EpisodesUpdated extends EpisodesEvent {
  final List<EpisodeEntity> episodes;

  const _EpisodesUpdated(this.episodes);

  @override
  List<Object> get props => [episodes];
}

// Internal event that is fired when the podcast filter settings change
class _FilterSettingsChanged extends EpisodesEvent {
  final PodcastFilterSettingsEntity newSettings;

  const _FilterSettingsChanged(this.newSettings);

  @override
  List<Object> get props => [newSettings];
}


class RefreshEpisodes extends EpisodesEvent {
  final int feedId;
  final bool isSubscribed;

  const RefreshEpisodes({
    required this.feedId,
    required this.isSubscribed,
  });

  @override
  List<Object?> get props => [feedId, isSubscribed];
}

// Event fired when a notification is shown after refresh
class NotificationShownEvent extends EpisodesEvent {}
