import 'package:objectbox/objectbox.dart';
import 'package:podcast/domain/entities/podcast_filter_settings_entity.dart';

@Entity()
class PersistentPodcastSettingsEntity {
  @Id()
  int id = 0;

  @Index()
  int podcastId;

  // The 5 persistent settings
  bool filterExplicitEpisodes;
  bool filterTrailerEpisodes;
  bool filterBonusEpisodes;
  int? minEpisodeDurationMinutes;
  bool autoplayEnabled;

  PersistentPodcastSettingsEntity({
    required this.podcastId,
    this.filterExplicitEpisodes = false,
    this.filterTrailerEpisodes = false,
    this.filterBonusEpisodes = false,
    this.minEpisodeDurationMinutes,
    this.autoplayEnabled = false,
  });

  // Convert this to a PodcastFilterSettingsEntity
  PodcastFilterSettingsEntity toFilterSettings({
    // Default values for non persistent settings
    bool initialFilterRead = true, // Default: hide read episodes
    EpisodeSortProperty initialSortProperty = EpisodeSortProperty.datePublished,
    SortDirection initialSortDirection = SortDirection.descending,
  }) {
    return PodcastFilterSettingsEntity(
      podcastId: podcastId,
      filterExplicitEpisodes: filterExplicitEpisodes,
      filterTrailerEpisodes: filterTrailerEpisodes,
      filterBonusEpisodes: filterBonusEpisodes,
      minEpisodeDurationMinutes: minEpisodeDurationMinutes,
      autoplayEnabled: autoplayEnabled,

      // Here the UI filters with their defaults or the current values from another state
      filterRead: initialFilterRead,
      showOnlyUnfinished: false,
      showOnlyFavorites: false,
      showOnlyDownloaded: false,
      filterByText: false,
      transientSearchText: null,
      sortProperty: initialSortProperty,
      sortDirection: initialSortDirection,
    );
  }

  static PersistentPodcastSettingsEntity defaultPersistentSettings(int podcastId) {
    return PersistentPodcastSettingsEntity(
      podcastId: podcastId,
      filterExplicitEpisodes: false,
      filterTrailerEpisodes: false,
      filterBonusEpisodes: false,
      autoplayEnabled: false,
    );
  }
}
