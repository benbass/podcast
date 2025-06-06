import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/episode_selection_cubit/episode_selection_cubit.dart';
import '../../../application/podcast_bloc/podcast_bloc.dart';
import 'iconbutton_with_popup_text.dart';

class RowIconButtonsEpisodes extends StatelessWidget {
  const RowIconButtonsEpisodes({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final podcastBloc = BlocProvider.of<PodcastBloc>(context);
    PodcastState state = context.watch<PodcastBloc>().state;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const IconButtonWithPopupText(),
        BlocBuilder<EpisodeSelectionCubit, EpisodeSelectionState>(
          builder: (context, state) {
            return IconButton(
              onPressed: () {
                BlocProvider.of<EpisodeSelectionCubit>(context)
                    .toggleSelectionMode();
              },
              icon: Icon(
                state.isSelectionModeActive
                    ? Icons.close_rounded
                    : Icons.library_add_check_rounded,
                size: 30,
              ),
            );
          },
        ),
        if (state.currentPodcast.subscribed)
          IconButton(
            onPressed: () {
              podcastBloc.add(RefreshEpisodesByFeedIdEvent(
                  feedId: state.currentPodcast.pId));
            },
            icon: const Icon(
              Icons.refresh_rounded,
              size: 30,
            ),
          ),
        if (state.currentPodcast.subscribed)
          IconButton(
            onPressed: () {
              _showFilterDialog(context, podcastBloc, state);
            },
            icon: Icon(
              state.episodesFilterStatus.name == "read"
                  ? Icons.filter_alt_off_outlined
                  : Icons.filter_alt_outlined,
              size: 30,
            ),
          ),
      ],
    );
  }

  _showFilterDialog(
      BuildContext context, PodcastBloc podcastBloc, PodcastState state) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Filter Episodes"),
            content: const Text("Select the filter option"),
            actionsAlignment: MainAxisAlignment.center,
            actionsOverflowAlignment: OverflowBarAlignment.center,
            alignment: Alignment.center,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            actions: [
              TextButton(
                onPressed: () {
                  podcastBloc.add(
                    ToggleEpisodesFilterStatusEvent(
                      filterStatus:
                          state.episodesFilterStatus.name == "hideRead"
                              ? "all"
                              : "hideRead",
                    ),
                  );
                  Navigator.of(context).pop();
                },
                child: Text(
                  state.episodesFilterStatus.name == "hideRead"
                      ? "Show read episodes"
                      : "Hide read episodes",
                  textAlign: TextAlign.center,
                ),
              ),
              TextButton(
                onPressed: () {
                  podcastBloc.add(
                    ToggleEpisodesFilterStatusEvent(
                      filterStatus:
                          state.episodesFilterStatus.name == "unfinished"
                              ? "hideRead"
                              : "unfinished",
                    ),
                  );
                  Navigator.of(context).pop();
                },
                child: Text(
                  state.episodesFilterStatus.name == "unfinished"
                      ? "Show all"
                      : "Show only unfinished",
                  textAlign: TextAlign.center,
                ),
              ),
              TextButton(
                onPressed: () {
                  podcastBloc.add(
                    ToggleEpisodesFilterStatusEvent(
                      filterStatus:
                          state.episodesFilterStatus.name == "favorites"
                              ? "hideRead"
                              : "favorites",
                    ),
                  );
                  Navigator.of(context).pop();
                },
                child: Text(
                  state.episodesFilterStatus.name == "favorites"
                      ? "Show all"
                      : "Show only favorites",
                  textAlign: TextAlign.center,
                ),
              ),
              TextButton(
                onPressed: () {
                  podcastBloc.add(
                    ToggleEpisodesFilterStatusEvent(
                      filterStatus:
                          state.episodesFilterStatus.name == "downloaded"
                              ? "hideRead"
                              : "downloaded",
                    ),
                  );
                  Navigator.of(context).pop();
                },
                child: Text(
                  state.episodesFilterStatus.name == "downloaded"
                      ? "Show all"
                      : "Show only downloaded",
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        });
  }
}
