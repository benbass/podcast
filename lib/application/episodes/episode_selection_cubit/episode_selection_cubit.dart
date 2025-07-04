import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/episode_entity.dart';
part 'episode_selection_state.dart';

class EpisodeSelectionCubit extends Cubit<EpisodeSelectionState> {
  EpisodeSelectionCubit() : super(const EpisodeSelectionState());

  void toggleSelectionMode() {
    final newMode = !state.isSelectionModeActive;
    emit(state.copyWith(
      isSelectionModeActive: newMode,
      // When the selection mode is deactivated, clear the selected episodes
      selectedEpisodes: newMode ? state.selectedEpisodes : [],
    ));
  }

  // Method to add or remove an episode to/from the selection
  void toggleEpisodeSelection(EpisodeEntity episode) {
    if (!state.isSelectionModeActive) return;

    final List<EpisodeEntity> currentSelected =
        List.from(state.selectedEpisodes);
    final isCurrentlySelected = currentSelected.any((e) => e.id == episode.id);

    if (isCurrentlySelected) {
      currentSelected.removeWhere((e) => e.id == episode.id);
    } else {
      currentSelected.add(episode);
    }
    emit(state.copyWith(selectedEpisodes: currentSelected));
  }

  void selectAllEpisodes(List<EpisodeEntity> allEpisodes) {
    if (!state.isSelectionModeActive) return;
    emit(state.copyWith(selectedEpisodes: List.from(allEpisodes)));
  }

  void deselectAllEpisodes() {
    if (!state.isSelectionModeActive) return;
    emit(state.copyWith(selectedEpisodes: []));
  }

  // Method to check if a specific episode is selected
  bool isEpisodeSelected(EpisodeEntity episode) {
    return state.selectedEpisodes.any((e) => e.id == episode.id);
  }
}
