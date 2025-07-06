import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/presentation/audioplayer_overlays/audioplayer_overlays.dart';
import 'package:podcast/presentation/user_playlist/widgets/user_playlist_list_item.dart';
import 'package:podcast/presentation/user_playlist/widgets/user_playlist_page_appbar.dart';

import '../../application/playback/playback_cubit/playback_cubit.dart';
import '../../application/podcast/podcast_bloc/podcast_bloc.dart';
import '../../application/user_playlist/user_playlist_cubit/user_playlist_cubit.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/podcast_entity.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';
import '../custom_widgets/effects/backdropfilter.dart';
import '../custom_widgets/effects/opacity_body.dart';
import '../custom_widgets/page_transition.dart';
import '../episode_details_page/episode_details_page.dart';

class UserPlaylistPage extends StatelessWidget {
  const UserPlaylistPage({super.key});

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
    context.read<UserPlaylistCubit>().loadPlaylist();
    return Scaffold(
      appBar:
          UserPlaylistPageAppBar.buildPlaylistPageAppBar(context, themeData),
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
            BlocConsumer<UserPlaylistCubit, UserPlaylistState>(
              listener: (context, state) {
                if (state is UserPlaylistError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red),
                  );
                } else if (state is UserPlaylistMessage) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is UserPlaylistLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is UserPlaylistError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<UserPlaylistCubit>().loadPlaylist(),
                          child: const Text('Try again'),
                        )
                      ],
                    ),
                  );
                }

                if (state is UserPlaylistLoaded) {
                  final List<EpisodeEntity> episodes = state.userPlaylist;
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

                        return UserPlaylistListItem(
                          key: ValueKey(episode.eId),
                          themeData: themeData,
                          index: index,
                          episode: episode,
                          podcast: podcast,
                          onPlayTap: () => isPlayingThisEpisode
                              ? getIt<MyAudioHandler>()
                                  .handlePlayPauseFromCard(context)
                              : getIt<MyAudioHandler>().playEpisodeFromCard(
                                  context,
                                  index,
                                  episode,
                                  episodes,
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
                                  .read<UserPlaylistCubit>()
                                  .removeEpisodeIdFromPlaylist(episode.id);
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
                            .read<UserPlaylistCubit>()
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
}
