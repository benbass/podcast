import 'package:equatable/equatable.dart';
import 'package:podcast/domain/entities/persistent_podcast_settings_entity.dart';

// Enums bleiben hier oder werden global definiert
enum EpisodeSortProperty { datePublished, duration, title }
enum SortDirection { ascending, descending }

class PodcastFilterSettingsEntity extends Equatable {

  final int podcastId;

  // Persistente Einstellungen (kommen aus PersistentPodcastSettingsEntity)
  final bool filterExplicitEpisodes;
  final bool filterTrailerEpisodes;
  final bool filterBonusEpisodes;
  final int? minEpisodeDurationMinutes;

  // UI-spezifische Filter (werden im State des UI-Layers oder im EpisodesBloc gehalten)
  final bool filterRead;
  final bool showOnlyRead;
  final bool showOnlyUnfinished;
  final bool showOnlyFavorites;
  final bool showOnlyDownloaded;
  final bool filterByText;
  final String? transientSearchText;
  final EpisodeSortProperty sortProperty;
  final SortDirection sortDirection;

  const PodcastFilterSettingsEntity({
    required this.podcastId,
    // Persistente Defaults
    this.filterExplicitEpisodes = false,
    this.filterTrailerEpisodes = false,
    this.filterBonusEpisodes = false,
    this.minEpisodeDurationMinutes,
    // UI-Filter Defaults
    this.filterRead = true,
    this.showOnlyRead = false,
    this.showOnlyUnfinished = false,
    this.showOnlyFavorites = false,
    this.showOnlyDownloaded = false,
    this.filterByText = false,
    this.transientSearchText,
    this.sortProperty = EpisodeSortProperty.datePublished,
    this.sortDirection = SortDirection.descending,
  });

  // copyWith bleibt größtenteils gleich, aber ohne `id`
  PodcastFilterSettingsEntity copyWith({
    int? podcastId,
    bool? filterExplicitEpisodes,
    bool? filterTrailerEpisodes,
    bool? filterBonusEpisodes,
    int? minEpisodeDurationMinutes,
    bool? filterRead,
    bool? showOnlyRead,
    bool? showOnlyUnfinished,
    bool? showOnlyFavorites,
    bool? showOnlyDownloaded,
    bool? filterByText,
    String? transientSearchText,
    EpisodeSortProperty? sortProperty,
    SortDirection? sortDirection,
  }) {
    return PodcastFilterSettingsEntity(
      podcastId: podcastId ?? this.podcastId,
      filterExplicitEpisodes: filterExplicitEpisodes ?? this.filterExplicitEpisodes,
      filterTrailerEpisodes: filterTrailerEpisodes ?? this.filterTrailerEpisodes,
      filterBonusEpisodes: filterBonusEpisodes ?? this.filterBonusEpisodes,
      minEpisodeDurationMinutes: minEpisodeDurationMinutes ?? this.minEpisodeDurationMinutes,
      filterRead: filterRead ?? this.filterRead,
      showOnlyRead: showOnlyRead ?? this.showOnlyRead,
      showOnlyUnfinished: showOnlyUnfinished ?? this.showOnlyUnfinished,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
      showOnlyDownloaded: showOnlyDownloaded ?? this.showOnlyDownloaded,
      filterByText: filterByText ?? this.filterByText,
      transientSearchText: transientSearchText ?? this.transientSearchText,
      sortProperty: sortProperty ?? this.sortProperty,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }

  // defaultSettings bleibt gleich
  static PodcastFilterSettingsEntity defaultSettings({required int podcastId}) {
    return PodcastFilterSettingsEntity(podcastId: podcastId);
  }

  PersistentPodcastSettingsEntity toPersistent() {
    return PersistentPodcastSettingsEntity(
      podcastId: podcastId,
      filterExplicitEpisodes: filterExplicitEpisodes,
      filterTrailerEpisodes: filterTrailerEpisodes,
      filterBonusEpisodes: filterBonusEpisodes,
    );
  }

  // props bleibt gleich (ohne id)
  @override
  List<Object?> get props => [
    podcastId,
    filterExplicitEpisodes,
    filterTrailerEpisodes,
    filterBonusEpisodes,
    minEpisodeDurationMinutes,
    filterRead,
    showOnlyRead,
    showOnlyUnfinished,
    showOnlyFavorites,
    showOnlyDownloaded,
    filterByText,
    transientSearchText,
    sortProperty,
    sortDirection,
  ];
}