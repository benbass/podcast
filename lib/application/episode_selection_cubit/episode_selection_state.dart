part of 'episode_selection_cubit.dart';

class EpisodeSelectionState extends Equatable {
  final bool isSelectionModeActive;
  final List<EpisodeEntity> selectedEpisodes;

  const EpisodeSelectionState({
    this.isSelectionModeActive = false,
    this.selectedEpisodes = const [],
  });

  EpisodeSelectionState copyWith({
    bool? isSelectionModeActive,
    List<EpisodeEntity>? selectedEpisodes,
  }) {
    return EpisodeSelectionState(
      isSelectionModeActive:
          isSelectionModeActive ?? this.isSelectionModeActive,
      selectedEpisodes: selectedEpisodes ?? this.selectedEpisodes,
    );
  }

  @override
  List<Object?> get props => [isSelectionModeActive, selectedEpisodes];
}
