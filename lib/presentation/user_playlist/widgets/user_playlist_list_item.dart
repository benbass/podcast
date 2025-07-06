import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/playback/playback_cubit/playback_cubit.dart';
import '../../../domain/entities/episode_entity.dart';
import '../../../domain/entities/podcast_entity.dart';
import '../../../helpers/core/utilities/image_provider.dart';
import '../../custom_widgets/playback_linear_progress_indicator.dart';

class UserPlaylistListItem extends StatelessWidget {
  final ThemeData themeData;
  final int index;
  final EpisodeEntity episode;
  final PodcastEntity podcast;
  final VoidCallback onPlayTap;
  final VoidCallback onTap;
  final VoidCallback onRemoveTap;

  const UserPlaylistListItem({
    required Key key,
    required this.themeData,
    required this.index,
    required this.episode,
    required this.podcast,
    required this.onPlayTap,
    required this.onTap,
    required this.onRemoveTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackCubit, PlaybackState>(
      builder: (context, state) {
        final bool isCurrentlyPlayingThisEpisode =
            state.episode?.eId == episode.eId;

        final bool isAudioPlaying = isCurrentlyPlayingThisEpisode &&
            state.playbackStatus == PlaybackStatus.playing;

        return Dismissible(
          key: ValueKey("dismiss_${episode.eId}"),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            onRemoveTap();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${episode.title} was removed.')),
            );
          },
          background: Container(
            color: themeData.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: AlignmentDirectional.centerEnd,
            child: Icon(
              Icons.delete_outline_rounded,
              color: themeData.colorScheme.primary,
              size: 30,
            ),
          ),
          child: FutureBuilder<ImageProvider>(
              future: MyImageProvider(
                  url: episode.image.isNotEmpty
                      ? episode.image
                      : podcast.artworkFilePath != null
                      ? podcast.artworkFilePath!
                      : podcast.artwork)
                  .imageProvider,
              builder: (BuildContext context,
                  AsyncSnapshot<ImageProvider> snapshot) {
                final ImageProvider imageProvider = snapshot.hasData
                    ? snapshot.data!
                    : const AssetImage('assets/placeholder.png');
                return BlocBuilder<PlaybackCubit, PlaybackState>(
                  builder: (context, currentlyPlayingEpisodeState) {
                    return Card(
                      color: isCurrentlyPlayingThisEpisode
                          ? themeData.colorScheme.onPrimary
                          .withValues(alpha: 0.4)
                          : Colors.black12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),),
                      elevation: 4.0,
                      shadowColor: Colors.black12,
                      //margin: const EdgeInsets.all(8.0),
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        height: 120.0,
                        width: MediaQuery.of(context).size.width,
                        child: InkWell(
                          splashColor: Colors.black87,
                          onTap: onTap,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 120.0,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
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
                                          8.0, 8.0, 8.0, 0.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                            context)
                                                            .size
                                                            .width /
                                                            2,
                                                        minWidth: MediaQuery.of(
                                                            context)
                                                            .size
                                                            .width /
                                                            2),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      mainAxisSize:
                                                      MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          episode.title,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          softWrap: true,
                                                          maxLines: 2,
                                                          style: themeData
                                                              .textTheme
                                                              .bodyMedium,
                                                        ),
                                                        Text(
                                                          episode.podcast
                                                              .target!.title,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          softWrap: true,
                                                          maxLines: 1,
                                                          style: themeData
                                                              .textTheme
                                                              .bodyLarge,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  isAudioPlaying
                                                      ? Icons
                                                      .pause_circle_filled
                                                      : Icons.play_circle_fill,
                                                ),
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                iconSize: 40,
                                                onPressed: onPlayTap,
                                              ),
                                            ],
                                          ),
                                          Icon(
                                            Icons.drag_handle,
                                            color:
                                            themeData.colorScheme.onPrimary,
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
              }),
        );
      },
    );
  }
}