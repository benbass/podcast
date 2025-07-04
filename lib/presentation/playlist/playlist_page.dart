import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/application/podcast_bloc/podcast_bloc.dart';
import 'package:podcast/presentation/audioplayer_overlays/audioplayer_overlays.dart';
import 'package:podcast/presentation/playlist/widgets/playlist_list_item.dart';
import 'package:podcast/presentation/playlist/widgets/playlist_page_appbar.dart';

import '../../application/playback_cubit/playback_cubit.dart';
import '../../application/playlist_details_cubit/playlist_details_cubit.dart';
import '../../core/globals.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/podcast_entity.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';
import '../custom_widgets/effects/backdropfilter.dart';
import '../custom_widgets/effects/opacity_body.dart';
import '../custom_widgets/page_transition.dart';
import '../episode_details_page/episode_details_page.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({super.key});

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
      appBar: PlaylistPageAppBar.buildPlaylistPageAppBar(context, themeData),
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

                        return PlaylistListItem(
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
          origin: globalPlaylistId.toString(),
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
}
