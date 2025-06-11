part of 'episodes_bloc.dart';

enum EpisodesStatus { initial, loading, success, failure, refreshing }

class EpisodesState extends Equatable {
  const EpisodesState({
    this.status = EpisodesStatus.initial,
    this.episodes = const <EpisodeEntity>[],
    this.feedId,
    this.podcastTitle = '',
    this.isSubscribed = false,
    this.activeFilters,
    this.filterText,
    this.errorMessage,
  });

  final EpisodesStatus status;
  final List<EpisodeEntity> episodes;
  final int? feedId;
  final String podcastTitle;
  final bool isSubscribed;
  final PodcastFilterSettingsEntity? activeFilters;
  final String? filterText;
  final String? errorMessage;

  EpisodesState copyWith({
    EpisodesStatus? status,
    List<EpisodeEntity>? episodes,
    int? feedId,
    String? podcastTitle,
    bool? isSubscribed,
    PodcastFilterSettingsEntity? activeFilters,
    String? filterText,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return EpisodesState(
      status: status ?? this.status,
      episodes: episodes ?? this.episodes,
      feedId: feedId ?? this.feedId,
      podcastTitle: podcastTitle ?? this.podcastTitle,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      activeFilters: activeFilters ?? this.activeFilters,
      filterText: filterText ?? this.filterText,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    episodes,
    feedId,
    podcastTitle,
    isSubscribed,
    activeFilters,
    filterText,
    errorMessage,
  ];
}