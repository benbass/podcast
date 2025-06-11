import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/custom_widgets/playback_linear_progress_indicator.dart';

import '../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../application/episode_selection_cubit/episode_selection_cubit.dart';
import '../../domain/entities/episode_entity.dart';
import '../../helpers/core/utilities/format_utilities.dart';
import '../../helpers/core/utilities/image_provider.dart';
import 'dialogs/episode_actions_dialog.dart';
import 'episode_actions_row.dart';
import 'page_transition.dart';
import '../episode_details_page/episode_details_page.dart';

class EpisodeCard extends StatelessWidget {
  const EpisodeCard({
    super.key,
    required this.episodes,
    required this.episode,
    required this.podcast,
  });

  final List<EpisodeEntity> episodes;
  final EpisodeEntity episode;
  final PodcastEntity podcast;

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
              Color cardColor = isSelected
                  ? themeData.colorScheme.secondary
                  : themeData.colorScheme.primaryContainer;
              return BlocBuilder<EpisodePlaybackCubit, EpisodePlaybackState>(
                builder: (context, currentlyPlayingEpisodeState) {
                  final isCurrentlyPlaying =
                      currentlyPlayingEpisodeState.episode?.eId == episode.eId;
                  return Card(
                    key: ValueKey(episode.eId),
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: isCurrentlyPlaying
                            ? BorderSide(
                                color: themeData.colorScheme.secondary,
                                width: 2.0,
                              )
                            : BorderSide.none),
                    elevation: 5.0,
                    shadowColor: Colors.black,
                    //margin: const EdgeInsets.all(8.0),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxWidth: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2,
                                                  minWidth: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2),
                                              child: _buildEpisodeDetails(themeData),
                                            ),
                                            const SizedBox(
                                              width: 40,
                                            ),
                                            if (episode.isSubscribed)
                                              IconButton(
                                                onPressed: () => EpisodeActionsDialog
                                                    .showEpisodeActionsDialog(
                                                        context, episode),
                                                icon: const Icon(
                                                  Icons.more_horiz_rounded,
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (episode.isSubscribed) _buildEpisodeIconsRow(context),
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
