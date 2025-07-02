import 'package:equatable/equatable.dart';
import 'package:podcast/domain/entities/persistent_podcast_settings_entity.dart';

enum EpisodeSortProperty { datePublished, duration, title }

enum SortDirection { ascending, descending }

class PodcastFilterSettingsEntity extends Equatable {
  final int podcastId;

  // Persistent settings (from PersistentPodcastSettingsEntity)
  final bool filterExplicitEpisodes;
  final bool filterTrailerEpisodes;
  final bool filterBonusEpisodes;
  final int? minEpisodeDurationMinutes;
  final bool autoplayEnabled;

  // UI specific settings (they are hold in the state of the UI-Layer or in the EpisodesBloc)
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
    // Persistent defaults
    this.filterExplicitEpisodes = false,
    this.filterTrailerEpisodes = false,
    this.filterBonusEpisodes = false,
    this.minEpisodeDurationMinutes,
    this.autoplayEnabled = false,
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

  PodcastFilterSettingsEntity copyWith({
    int? podcastId,
    bool? filterExplicitEpisodes,
    bool? filterTrailerEpisodes,
    bool? filterBonusEpisodes,
    int? minEpisodeDurationMinutes,
    bool? autoplayEnabled,
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
      filterExplicitEpisodes:
          filterExplicitEpisodes ?? this.filterExplicitEpisodes,
      filterTrailerEpisodes:
          filterTrailerEpisodes ?? this.filterTrailerEpisodes,
      filterBonusEpisodes: filterBonusEpisodes ?? this.filterBonusEpisodes,
      minEpisodeDurationMinutes:
          minEpisodeDurationMinutes ?? this.minEpisodeDurationMinutes,
      autoplayEnabled: autoplayEnabled ?? this.autoplayEnabled,
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

  // defaultSettings does not change
  static PodcastFilterSettingsEntity defaultSettings({required int podcastId}) {
    return PodcastFilterSettingsEntity(podcastId: podcastId);
  }

  PersistentPodcastSettingsEntity toPersistent() {
    return PersistentPodcastSettingsEntity(
      podcastId: podcastId,
      filterExplicitEpisodes: filterExplicitEpisodes,
      filterTrailerEpisodes: filterTrailerEpisodes,
      filterBonusEpisodes: filterBonusEpisodes,
      autoplayEnabled: autoplayEnabled,
    );
  }

  @override
  List<Object?> get props => [
        podcastId,
        filterExplicitEpisodes,
        filterTrailerEpisodes,
        filterBonusEpisodes,
        minEpisodeDurationMinutes,
        autoplayEnabled,
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
