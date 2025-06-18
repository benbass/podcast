import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/application/episodes_bloc/episodes_bloc.dart';

import '../../../application/episode_selection_cubit/episode_selection_cubit.dart';
import '../../../application/podcast_bloc/podcast_bloc.dart';
import '../../../application/podcast_settings_cubit/podcast_settings_cubit.dart';
import 'iconbutton_with_popup_text.dart';

class RowIconButtonsEpisodes extends StatelessWidget {
  const RowIconButtonsEpisodes({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final PodcastState podcastState = context.watch<PodcastBloc>().state;

    final PodcastSettingsCubit podcastSettingsCubit =
        BlocProvider.of<PodcastSettingsCubit>(context);
    final PodcastSettingsState podcastSettingsState =
        podcastSettingsCubit.state;

    final EpisodesBloc episodesBloc = BlocProvider.of<EpisodesBloc>(context);
    final EpisodesState episodesState = context.watch<EpisodesBloc>().state;

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
          Stack(children: [
            if (episodesState.status != EpisodesStatus.refreshing)
              IconButton(
                onPressed: () async {
                  final int currentCount = context.read<EpisodesBloc>().state.episodes.length;
                  episodesBloc.add(RefreshEpisodes(
                    feedId: podcastState.currentPodcast.pId,
                    podcastTitle: podcastState.currentPodcast.title,
                    isSubscribed: podcastState.currentPodcast.subscribed,
                  ));
                  Duration duration = const Duration(milliseconds: 1500);
                  try {
                    final finalState = await episodesBloc.stream.firstWhere(
                        (state) =>
                            state.status != EpisodesStatus.refreshing &&
                            state.status != EpisodesStatus.loading);

                    if (context.mounted) {
                      if (finalState.status == EpisodesStatus.success) {
                        final int newCount = finalState.episodes.length;
                        final int diff = newCount - currentCount;

                        if (diff > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                duration: duration,
                                content: Text("$diff new episodes.")),
                          );
                        } else if (diff == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                duration: duration,
                                content:
                                    const Text("No new episodes.")),
                          );
                        } else {
                          // diff < 0 (episodes removed??),
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                duration: duration,
                                content: const Text("Episodes were updated.")),
                          );
                        }
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            duration: duration,
                            content: const Text("An error occurred.")),
                      );
                    }
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 30,
                ),
              ),
            if (episodesState.status == EpisodesStatus.refreshing)
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),
          ]),
        const SizedBox(width: 30),
        if (podcastState.currentPodcast.subscribed &&
            podcastSettingsState is PodcastSettingsLoaded)
          IconButton(
            onPressed: () {
              _showFilterDialog(context, podcastSettingsCubit);
            },
            icon: Icon(
              podcastSettingsState.settings.filterByText ||
                      podcastSettingsState.settings.showOnlyUnfinished ||
                      podcastSettingsState.settings.showOnlyFavorites ||
                      podcastSettingsState.settings.showOnlyDownloaded
                  ? Icons.filter_alt_off_outlined
                  : Icons.filter_alt_outlined,
              size: 30,
            ),
          ),
      ],
    );
  }

  _showFilterDialog(BuildContext context, PodcastSettingsCubit episodesBloc) {
    final episodesState = episodesBloc.state;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          if (episodesState is PodcastSettingsLoaded) {
            return Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Container(color: Colors.black26),
                ),
                AlertDialog(
                  title: const Text(
                    "Filter Episodes",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Close",
                      ),
                    ),
                  ],
                  actionsAlignment: MainAxisAlignment.center,
                  actionsOverflowAlignment: OverflowBarAlignment.center,
                  alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () {
                          context
                              .read<PodcastSettingsCubit>()
                              .updateUiFilterSettings(
                                filterRead: episodesState.settings.filterRead
                                    ? false
                                    : true,
                              );
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          episodesState.settings.filterRead
                              ? "Show read episodes"
                              : "Hide read episodes",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context
                              .read<PodcastSettingsCubit>()
                              .updateUiFilterSettings(
                                showOnlyUnfinished:
                                    episodesState.settings.showOnlyUnfinished
                                        ? false
                                        : true,
                                showOnlyFavorites: false,
                                showOnlyDownloaded: false,
                              );
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          episodesState.settings.showOnlyUnfinished
                              ? "Show all"
                              : "Show only unfinished",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context
                              .read<PodcastSettingsCubit>()
                              .updateUiFilterSettings(
                                showOnlyFavorites:
                                    episodesState.settings.showOnlyFavorites
                                        ? false
                                        : true,
                                showOnlyDownloaded: false,
                                showOnlyUnfinished: false,
                              );
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          episodesState.settings.showOnlyFavorites
                              ? "Show all"
                              : "Show only favorites",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context
                              .read<PodcastSettingsCubit>()
                              .updateUiFilterSettings(
                                showOnlyDownloaded:
                                    episodesState.settings.showOnlyDownloaded
                                        ? false
                                        : true,
                                showOnlyUnfinished: false,
                                showOnlyFavorites: false,
                              );
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          episodesState.settings.showOnlyDownloaded
                              ? "Show all"
                              : "Show only downloaded",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Container(
                    color: Colors.black26,
                  ),
                ),
                const AlertDialog(
                  title: Text(
                    "Filter Episodes",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: CircularProgressIndicator(),
                ),
              ],
            );
          }
        });
  }
}
