import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/application/episodes_bloc/episodes_bloc.dart';

import '../../../application/episode_selection_cubit/episode_selection_cubit.dart';
import '../../../application/podcast_bloc/podcast_bloc.dart';
import 'iconbutton_with_popup_text.dart';

class RowIconButtonsEpisodes extends StatelessWidget {
  const RowIconButtonsEpisodes({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final PodcastState podcastState = context.watch<PodcastBloc>().state;
    final EpisodesBloc episodesBloc = BlocProvider.of<EpisodesBloc>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: [
        const IconButtonWithPopupText(),
        const SizedBox(width: 30),
        BlocBuilder<EpisodeSelectionCubit, EpisodeSelectionState>(
          builder: (context, episodeSelectionState) {
            return IconButton(
              onPressed: () {
                BlocProvider.of<EpisodeSelectionCubit>(context)
                    .toggleSelectionMode();
              },
              icon: Icon(
                episodeSelectionState.isSelectionModeActive
                    ? Icons.close_rounded
                    : Icons.library_add_check_rounded,
                size: 30,
              ),
            );
          },
        ),
        const SizedBox(width: 30),
        if (podcastState.currentPodcast.subscribed)
          Stack(
            children: [
                BlocListener<EpisodesBloc, EpisodesState>(
                  listener: (context, state) {
                    if (state.wasRefreshOperation == true) {
                      if (state.status == EpisodesStatus.success &&
                          state.newlyAddedCount != null) {
                        final int diff = state.newlyAddedCount!;
                        Duration duration = const Duration(milliseconds: 1500);
                        String message;
                        if (diff > 0) {
                          message = "$diff new episodes.";
                        } else if (diff == 0) {
                          message = "No new episodes.";
                        } else {
                          message =
                              "Episodes were updated.";
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(duration: duration, content: Text(message)),
                        );
                      } else if (state.status == EpisodesStatus.failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(milliseconds: 1500),
                            content: Text(
                                state.errorMessage ?? "An error occurred."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      episodesBloc.add(NotificationShownEvent());
                    }
                  },
                  child: IconButton(
                    onPressed: () async {
                      episodesBloc.add(RefreshEpisodes(
                        feedId: podcastState.currentPodcast.pId,
                        podcastTitle: podcastState.currentPodcast.title,
                        isSubscribed: podcastState.currentPodcast.subscribed,
                      ));
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: (context.watch<EpisodesBloc>().state.status == EpisodesStatus.refreshing)
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh_rounded, size: 30),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
