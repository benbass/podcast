import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/application/podcast_bloc/podcast_bloc.dart';
import 'package:podcast/presentation/audioplayer_overlays/audioplayer_overlays.dart';

import '../../application/playback_cubit/playback_cubit.dart';
import '../../application/playlist_details_cubit/playlist_details_cubit.dart';
import '../../core/globals.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/podcast_entity.dart';
import '../../helpers/core/utilities/image_provider.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';
import '../custom_widgets/effects/backdropfilter.dart';
import '../custom_widgets/effects/opacity_body.dart';
import '../custom_widgets/page_transition.dart';
import '../custom_widgets/playback_linear_progress_indicator.dart';
import '../episode_details_page/episode_details_page.dart';

class PlaylistDetailsPage extends StatelessWidget {
  const PlaylistDetailsPage({super.key});

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, _) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final Color color = Color.lerp(
            Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.4),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4),
            animValue)!;

        return Material(
          elevation: 8.0,
          color: color,
          shadowColor: Colors.black,
          borderRadius: BorderRadius.circular(10.0),
          child: child, // Das Original-Widget
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    context.read<PlaylistDetailsCubit>().loadPlaylist();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlist'),
        actions: [
          // Autoplay Toggle Button
          BlocBuilder<PlaylistDetailsCubit, PlaylistDetailsState>(
            builder: (context, state) {
              if (state is PlaylistDetailsLoaded) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Autoplay ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    Switch(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      inactiveThumbColor: Colors.grey,
                      value: state.autoPlayEnabled,
                      onChanged: (value) {
                        // Update the persistent autoplay setting in the cubit
                        context
                            .read<PlaylistDetailsCubit>()
                            .updatePersistentSettings(value);
                      },
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _showClearPlaylistConfirmationDialog(context);
              }
            },
            color: themeData.colorScheme.primaryContainer,
            elevation: 8.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'clear',
                child: Text(
                  'Clear playlist',
                  style: themeData.textTheme.bodyLarge,
                ),
              ),
              // ...
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const OpacityBody(
              state: null,
            ),
            const BackdropFilterWidget(
              sigma: 4.0,
            ),
            BlocConsumer<PlaylistDetailsCubit, PlaylistDetailsState>(
              listener: (context, state) {
                if (state is PlaylistDetailsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red),
                  );
                } else if (state is PlaylistDetailsInfo) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is PlaylistDetailsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PlaylistDetailsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        ElevatedButton(
                          onPressed: () => context
                              .read<PlaylistDetailsCubit>()
                              .loadPlaylist(),
                          child: const Text('Try again'),
                        )
                      ],
                    ),
                  );
                }

                if (state is PlaylistDetailsLoaded) {
                  final List<EpisodeEntity> episodes = state.playlist;
                  final bool autoplayEnabled = state.autoPlayEnabled;
                  final episodePlaybackState =
                      context.read<PlaybackCubit>().state;

                  final int? currentPlayingIndex =
                      context.read<PlaybackCubit>().state.currentIndex;

                  if (episodes.isEmpty) {
                    return const Center(
                      child: Text('The playlist is empty.'),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                        0.0, 8.0, 0.0, overlayEntry == null ? 0 : 80.0),
                    child: ReorderableListView.builder(
                      physics: const BouncingScrollPhysics(),
                      proxyDecorator: _proxyDecorator,
                      itemCount: episodes.length,
                      itemBuilder: (context, index) {
                        final episode = episodes[index];
                        final EpisodeEntity? currentlyPlayingEpisode =
                            context.read<PlaybackCubit>().state.episode;
                        final bool isPlayingThisEpisode =
                            currentlyPlayingEpisode != null
                                ? currentlyPlayingEpisode.id == episode.id
                                : false;
                        final PodcastEntity podcast = episode.podcast.target!;

                        return _PlaylistListItem(
                          key: ValueKey(episode.eId),
                          themeData: themeData,
                          index: index,
                          episode: episode,
                          podcast: podcast,
                          onPlayTap: () => isPlayingThisEpisode
                              ? _handlePlayPause(context)
                              : _playEpisode(context, index, episode, episodes,
                                  autoplayEnabled),
                          onTap: () {
                            final podcast = episode.podcast.target!;
                            context
                                .read<PodcastBloc>()
                                .add(PodcastSelectedEvent(podcast: podcast));

                            Navigator.push(
                                context,
                                ScaleRoute(
                                  page: EpisodeDetailsPage(
                                    episodes: episodes,
                                    initialEpisode: episode,
                                  ),
                                ));
                          },
                          onRemoveTap: () async {
                            bool? isUserPlaylist =
                                episodePlaybackState.isUserPlaylist;
                            if (currentPlayingIndex != null && isUserPlaylist) {
                              if (context.mounted) {
                                context
                                    .read<PlaybackCubit>()
                                    .updateCurrentPlaylistAfterRemovingEpisode(
                                        indexToRemove: index);
                              }
                            }
                            if (context.mounted) {
                              await context
                                  .read<PlaylistDetailsCubit>()
                                  .removeEpisodeFromPlaylist(episode.id);
                            }
                          },
                        );
                      },
                      onReorder: (oldIndex, newIndex) {
                        bool? isUserPlaylist =
                            episodePlaybackState.isUserPlaylist;
                        // --- Update currentPlayingIndex ---
                        if (isUserPlaylist) {
                          context
                              .read<PlaybackCubit>()
                              .updateCurrentPlayingIndexAfterReorderingEpisode(
                                newIndex: newIndex,
                                oldIndex: oldIndex,
                              );
                        }
                        context
                            .read<PlaylistDetailsCubit>()
                            .reorderPlaylist(oldIndex, newIndex);
                      },
                    ),
                  );
                }

                return const Center(child: Text('Playlist is loading...'));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _playEpisode(
    BuildContext context,
    int index,
    EpisodeEntity episode,
    List<EpisodeEntity> episodes,
    bool autoplayEnabled,
  ) async {
    if (context.read<PlaybackCubit>().state.episode != null) {
      final previousEpisode = context.read<PlaybackCubit>().state.episode;
      previousEpisode!.position =
          getIt<MyAudioHandler>().player.position.inSeconds;
      episodeBox.put(previousEpisode);
    }
    await context.read<PlaybackCubit>().onPlay(
          episode: episode,
          playlist: episodes,
          isAutoplayEnabled: autoplayEnabled,
          currentIndex: index,
          isUserPlaylist: true,
        );

    await getIt<MyAudioHandler>().play();
    if (context.mounted && overlayEntry == null) {
      showOverlayPlayerMin(context);
    }
  }

  void _handlePlayPause(BuildContext context) {
    getIt<MyAudioHandler>().handlePlayPause();
    context.read<PlaybackCubit>().onPlayPause();
  }

  void _showClearPlaylistConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Stack(
          children: [
            const BackdropFilterWidget(sigma: 4.0),
            AlertDialog(
              title: const Text('Clear Playlist?'),
              content: const Text(
                  'Do you really want to remove all episodes from the playlist?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: const Text('Clear'),
                  onPressed: () {
                    context.read<PlaylistDetailsCubit>().clearPlaylist();
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// Dummy-Implementation: to be replaced
class _PlaylistListItem extends StatelessWidget {
  final ThemeData themeData;
  final int index;
  final EpisodeEntity episode;
  final PodcastEntity podcast;
  final VoidCallback onPlayTap;
  final VoidCallback onTap;
  final VoidCallback onRemoveTap;

  const _PlaylistListItem({
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
        final EpisodeEntity? currentlyPlayingEpisode = state.episode;

        final bool isCurrentlyPlayingThisEpisode =
            currentlyPlayingEpisode != null
                ? currentlyPlayingEpisode.id == episode.id
                : false;

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
                      color: isAudioPlaying
                          ? themeData.colorScheme.secondary
                              .withValues(alpha: 0.4)
                          : Colors.black12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: isAudioPlaying
                              ? BorderSide(
                                  color: themeData.colorScheme.secondary,
                                  width: 2.0,
                                )
                              : BorderSide.none),
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
                                                    .primary,
                                                iconSize: 30,
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
