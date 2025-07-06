import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/custom_widgets/playback_linear_progress_indicator.dart';

import '../../../application/episodes/episode_selection_cubit/episode_selection_cubit.dart';
import '../../../application/playback/playback_cubit/playback_cubit.dart';
import '../../../domain/entities/episode_entity.dart';
import '../../../helpers/core/utilities/format_utilities.dart';
import '../../../helpers/core/utilities/image_provider.dart';
import '../../../helpers/player/audiohandler.dart';
import '../../../injection.dart';
import '../../custom_widgets/dialogs/episode_actions_dialog.dart';
import '../../custom_widgets/episode_actions_row.dart';
import '../../custom_widgets/page_transition.dart';
import '../../episode_details_page/episode_details_page.dart';

class EpisodeCard extends StatelessWidget {
  const EpisodeCard({
    super.key,
    required this.episodes,
    required this.episode,
    required this.podcast,
    required this.index,
  });

  final List<EpisodeEntity> episodes;
  final EpisodeEntity episode;
  final PodcastEntity podcast;
  final int index;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    double dimension = 120.0;
    return FutureBuilder<ImageProvider>(
        future: MyImageProvider(
                url: episode.image.isNotEmpty
                    ? episode.image
                    : podcast.artworkFilePath != null
                        ? podcast.artworkFilePath!
                        : podcast.artwork)
            .imageProvider,
        builder: (BuildContext context, AsyncSnapshot<ImageProvider> snapshot) {
          final ImageProvider imageProvider = snapshot.hasData
              ? snapshot.data!
              : const AssetImage('assets/placeholder.png');
          return BlocBuilder<EpisodeSelectionCubit, EpisodeSelectionState>(
            builder: (context, selectedEpisodesState) {
              bool isSelected = BlocProvider.of<EpisodeSelectionCubit>(context)
                  .isEpisodeSelected(episode);

              return BlocBuilder<PlaybackCubit, PlaybackState>(
                builder: (context, currentlyPlayingEpisodeState) {
                  final isCurrentlyPlaying =
                      currentlyPlayingEpisodeState.episode?.eId == episode.eId;
                  Color cardColor = isSelected
                      ? themeData.colorScheme.secondary.withValues(alpha: 0.4)
                      : isCurrentlyPlaying
                          ? themeData.colorScheme.onPrimary
                              .withValues(alpha: 0.4)
                          : Colors.black12;
                  return Card(
                    key: ValueKey(episode.eId),
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 4.0,
                    shadowColor: Colors.black12,
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      height: dimension,
                      width: MediaQuery.of(context).size.width,
                      child: InkWell(
                        splashColor: Colors.black87,
                        onTap: () {
                          if (!selectedEpisodesState.isSelectionModeActive) {
                            _navigateToEpisodeDetails(context);
                          } else {
                            BlocProvider.of<EpisodeSelectionCubit>(context)
                                .toggleEpisodeSelection(episode);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEpisodeImage(
                              imageProvider,
                              dimension,
                            ),
                            Expanded(
                              child: Stack(
                                children: [
                                  PlaybackLinearProgressIndicator(
                                    themeData: themeData,
                                    episode: episode,
                                    currentlyPlayingEpisode:
                                        currentlyPlayingEpisodeState.episode,
                                    paddingVert: 0.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      6.0,
                                      8.0,
                                      0.0,
                                      0.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          2,
                                                  minWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          2),
                                              child: _buildEpisodeDetails(
                                                  themeData),
                                            ),
                                            const SizedBox(
                                              width: 36,
                                            ),
                                            if (episode.isSubscribed)
                                              IconButton(
                                                onPressed: () =>
                                                    EpisodeActionsDialog
                                                        .showEpisodeActionsDialog(
                                                            context, episode),
                                                icon: const Icon(
                                                  Icons.more_horiz_rounded,
                                                ),
                                              ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            if (episode.isSubscribed)
                                              _buildEpisodeIconsRow(context),
                                            SizedBox(width: 30.0),
                                            _buildPlayPauseButton(),
                                            SizedBox(width: 5.0),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        });
  }

  BlocBuilder<PlaybackCubit, PlaybackState> _buildPlayPauseButton() {
    return BlocBuilder<PlaybackCubit, PlaybackState>(
      builder: (context, state) {
        final EpisodeEntity? currentlyPlayingEpisode = state.episode;

        final bool isCurrentlyPlayingThisEpisode =
            currentlyPlayingEpisode != null
                ? currentlyPlayingEpisode.id == episode.id
                : false;

        final bool isAudioPlaying = isCurrentlyPlayingThisEpisode &&
            state.playbackStatus == PlaybackStatus.playing;
        return SizedBox(
          height: 40.0,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              isAudioPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,
            ),
            color: Theme.of(context).colorScheme.onPrimary,
            iconSize: 40,
            onPressed: () => isCurrentlyPlayingThisEpisode
                ? getIt<MyAudioHandler>().handlePlayPauseFromCard(context)
                : getIt<MyAudioHandler>().playEpisodeFromCard(
                    context,
                    index,
                    episode,
                    episodes,
                    episode.podcast.target!.persistentSettings.target!
                        .autoplayEnabled),
          ),
        );
      },
    );
  }

  void _navigateToEpisodeDetails(BuildContext context) {
    Navigator.push(
      context,
      ScaleRoute(
        page: EpisodeDetailsPage(
          episodes: episodes,
          initialEpisode: episode,
        ),
      ),
    );
  }

  Widget _buildEpisodeImage(ImageProvider imageProvider, double dimension) {
    return Container(
      width: dimension,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  Widget _buildEpisodeDetails(ThemeData themeData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          episode.title,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          maxLines: 2,
          style: themeData.textTheme.displayMedium,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          FormatUtilities.formatTimestamp(
            episode.datePublished,
          ),
          style: themeData.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildEpisodeIconsRow(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 40.0,
        child: EpisodeActionsRow(
          episode: episode,
        ),
      ),
    );
  }
}
