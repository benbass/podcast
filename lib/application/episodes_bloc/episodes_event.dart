part of 'episodes_bloc.dart';

abstract class EpisodesEvent extends Equatable {
  const EpisodesEvent();

  @override
  List<Object?> get props => [];
}

// Event, um Episoden für einen bestimmten Podcast zu laden/beobachten
class LoadEpisodes extends EpisodesEvent {
  final int feedId; // Die ID des Podcast-Feeds
  final String podcastTitle; // Für UI-Zwecke oder Fehlerbehandlung
  final bool isSubscribed;   // Ist der Podcast abonniert?
  final PodcastFilterSettingsEntity? initialFilterSettings; // Optionale initiale Filter

  const LoadEpisodes({
    required this.feedId,
    required this.podcastTitle,
    required this.isSubscribed,
    this.initialFilterSettings,
  });

  @override
  List<Object?> get props => [feedId, podcastTitle, isSubscribed, initialFilterSettings];
}

// Internes Event, das gefeuert wird, wenn der Stream neue Episoden liefert
class _EpisodesUpdated extends EpisodesEvent {
  final List<EpisodeEntity> episodes;

  const _EpisodesUpdated(this.episodes);

  @override
  List<Object> get props => [episodes];
}

// Internes Event, das gefeuert wird, wenn die Podcast-Filtereinstellungen sich ändern
class _FilterSettingsChanged extends EpisodesEvent {
  final PodcastFilterSettingsEntity newSettings;

  const _FilterSettingsChanged(this.newSettings);

  @override
  List<Object> get props => [newSettings];
}

// Event, um ein manuelles Neuladen/Aktualisieren vom Server zu erzwingen
class RefreshEpisodes extends EpisodesEvent {
  final int feedId;
  final String podcastTitle;
  final bool isSubscribed;

  const RefreshEpisodes({
    required this.feedId,
    required this.podcastTitle,
    required this.isSubscribed,
  });

  @override
  List<Object?> get props => [feedId, podcastTitle, isSubscribed];
}
