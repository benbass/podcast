import 'package:objectbox/objectbox.dart';
import 'package:podcast/domain/entities/podcast_filter_settings_entity.dart';

@Entity()
class PersistentPodcastSettingsEntity {
  @Id()
  int id = 0;

  @Index()
  int podcastId;

  // Die 4 persistenten Einstellungen
  bool filterExplicitEpisodes;
  bool filterTrailerEpisodes;
  bool filterBonusEpisodes;
  int? minEpisodeDurationMinutes;

  PersistentPodcastSettingsEntity({
    required this.podcastId,
    this.filterExplicitEpisodes = false,
    this.filterTrailerEpisodes = false,
    this.filterBonusEpisodes = false,
    this.minEpisodeDurationMinutes,
  });

  // Optional: eine Methode, um diese in die umfassendere PodcastFilterSettingsEntity zu konvertieren
  PodcastFilterSettingsEntity toFilterSettings({
    // Standardwerte für die nicht-persistenten UI-Filter
    bool initialFilterRead = true, // Default: Ungelesene anzeigen
    EpisodeSortProperty initialSortProperty = EpisodeSortProperty.datePublished,
    SortDirection initialSortDirection = SortDirection.descending,
  }) {
    return PodcastFilterSettingsEntity(
      podcastId: podcastId,
      filterExplicitEpisodes: filterExplicitEpisodes,
      filterTrailerEpisodes: filterTrailerEpisodes,
      filterBonusEpisodes: filterBonusEpisodes,
      minEpisodeDurationMinutes: minEpisodeDurationMinutes,
      // Hier die UI-Filter mit ihren Defaults oder aktuellen Werten aus einem anderen State
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

  static PersistentPodcastSettingsEntity defaultPersistentSettings(int feedId){
    return PersistentPodcastSettingsEntity(
      podcastId: feedId,
      filterExplicitEpisodes: false,
      filterTrailerEpisodes: false,
      filterBonusEpisodes: false,);
  }
}