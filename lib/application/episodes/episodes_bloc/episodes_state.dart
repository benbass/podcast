part of 'episodes_bloc.dart';

enum EpisodesStatus { initial, loading, success, failure, refreshing }

class EpisodesState extends Equatable {
  const EpisodesState({
    this.status = EpisodesStatus.initial,
    this.episodes = const <EpisodeEntity>[],
    this.feedId,
    this.isSubscribed = false,
    this.activeFilters,
    this.filterText,
    this.errorMessage,
    this.newlyAddedCount,
    this.wasRefreshOperation,

  });

  final EpisodesStatus status;
  final List<EpisodeEntity> episodes;
  final int? feedId;
  final bool isSubscribed;
  final PodcastFilterSettingsEntity? activeFilters;
  final String? filterText;
  final String? errorMessage;
  final int? newlyAddedCount;
  final bool? wasRefreshOperation;

  EpisodesState copyWith({
    EpisodesStatus? status,
    List<EpisodeEntity>? episodes,
    int? feedId,
    bool? isSubscribed,
    PodcastFilterSettingsEntity? activeFilters,
    String? filterText,
    String? errorMessage,
    bool clearErrorMessage = false,
    int? newlyAddedCount,
    bool? wasRefreshOperation,
    bool clearNewlyAddedCount = false,
    bool clearWasRefreshOperation = false,
  }) {
    return EpisodesState(
      status: status ?? this.status,
      episodes: episodes ?? this.episodes,
      feedId: feedId ?? this.feedId,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      activeFilters: activeFilters ?? this.activeFilters,
      filterText: filterText ?? this.filterText,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      newlyAddedCount: clearNewlyAddedCount ? null : (newlyAddedCount ?? this.newlyAddedCount),
      wasRefreshOperation: clearWasRefreshOperation ? null : (wasRefreshOperation ?? this.wasRefreshOperation),
    );
  }

  @override
  List<Object?> get props => [
    status,
    episodes,
    feedId,
    isSubscribed,
    activeFilters,
    filterText,
    errorMessage,
    newlyAddedCount,
    wasRefreshOperation,
  ];
}