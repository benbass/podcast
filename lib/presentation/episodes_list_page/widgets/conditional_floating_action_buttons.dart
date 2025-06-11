import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/application/episodes_bloc/episodes_bloc.dart';

import '../../../application/episode_selection_cubit/episode_selection_cubit.dart';
import '../../audioplayer_overlays/audioplayer_overlays.dart';
import '../../custom_widgets/dialogs/episode_actions_dialog.dart';

class ConditionalFloatingActionButtons extends StatelessWidget {
  const ConditionalFloatingActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EpisodeSelectionCubit, EpisodeSelectionState>(
      builder: (context, selectionState) {
        final bool showFABs = selectionState.isSelectionModeActive;

        if (!showFABs) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: overlayEntry != null ? 160.0 : 60.0,
          right: 16.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 20,
            children: <Widget>[
              FloatingActionButton(
                heroTag: 'fab_action_select_all',
                onPressed: () async {
                  final allEpisodes = context.read<EpisodesBloc>().state.episodes;
                  if(context.mounted) {
                    BlocProvider.of<EpisodeSelectionCubit>(context).selectAllEpisodes(allEpisodes);
                  }
                },
                tooltip: 'Select all',
                child: const Icon(Icons.select_all_rounded),
              ),
              FloatingActionButton(
                heroTag: 'fab_action_unselect_all',
                onPressed: () {
                  BlocProvider.of<EpisodeSelectionCubit>(context).deselectAllEpisodes();
                },
                tooltip: 'Unselect all',
                child: const Icon(Icons.deselect_rounded),
              ),
              FloatingActionButton.large(
                heroTag: 'fab_action_dialog',
                onPressed: () {
                  EpisodeActionsDialog.showSelectedEpisodesActionDialog(
                      context, selectionState.selectedEpisodes);
                },
                tooltip: 'Show action dialog',
                child: const Icon(Icons.more_vert_rounded),
              ),
            ],
          ),
        );
      },
    );
  }
}