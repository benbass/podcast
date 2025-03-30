import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../core/globals.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/podcast_entity.dart';
import '../../domain/usecases/episode_usecases.dart';
import '../../domain/usecases/podcast_usecases.dart';
import '../../helpers/core/format_pubdate_string.dart';
import '../../helpers/core/image_provider.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';
import '../custom_widgets/page_transition.dart';
import '../episode_details_page/episode_details_page.dart';

class FlaggedEpisodesPage extends StatelessWidget {
  final String flag;
  const FlaggedEpisodesPage({super.key, required this.flag});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    double dimension = 120.0;
    List<PodcastEntity> podcasts = podcastBox.getAll();

    Future<PodcastEntity> podcastForEpisode(EpisodeEntity episode) async {
      // Does podcast exist in db?
      PodcastEntity podcast = podcasts.firstWhere(
        (podcast) => podcast.pId == episode.feedId,
        orElse: () => PodcastEntity.emptyPodcast(),
      );
      // If not, fetch it from remote.
      if (podcast.pId == -1) {
        // emptyPodcast
        return await getIt<PodcastUseCases>()
            .fetchPodcastByFeedId(episode.feedId);
      }
      return podcast;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(flag, style: themeData.textTheme.displayLarge!),
      ),
      body: StreamBuilder(
        stream: getIt<EpisodeUseCases>().getFlaggedEpisodes(flag: flag),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('An error occurred while fetching your favorite episodes\nPlease try again.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No ${flag.toLowerCase()} found'));
          } else {
            final groupedEpisodes = snapshot.data!;
            return ListView.builder(
              itemCount: groupedEpisodes.length,
              itemBuilder: (context, index) {
                final podcastTitle = groupedEpisodes.keys.elementAt(index);
                final episodes = groupedEpisodes[podcastTitle]!;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: ExpansionTile(
                    title: Container(
                      decoration: BoxDecoration(
                        color: themeData.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        podcastTitle,
                        style: themeData.textTheme.displayLarge!.copyWith(
                          color: themeData.colorScheme.primaryContainer,
                        ),
                      ),
                    ),
                    initiallyExpanded: index == 0,
                    shape: const RoundedRectangleBorder(),
                    children: episodes.map((episode) {
                      return FutureBuilder<PodcastEntity>(
                          future: podcastForEpisode(episode),
                          builder: (context, snapshot) {
                            late PodcastEntity podcast;
                            if (snapshot.hasData) {
                              podcast = snapshot.data!;
                            } else {
                              podcast = PodcastEntity.emptyPodcast();
                            }
                            return FutureBuilder<ImageProvider>(
                                future: MyImageProvider(
                                        url: episode.image.isNotEmpty
                                            ? episode.image
                                            : podcast.artworkFilePath != null
                                                ? podcast.artworkFilePath!
                                                : podcast.artwork)
                                    .imageProvider,
                                builder: (BuildContext context,
                                    AsyncSnapshot<ImageProvider> snapshot) {
                                  final ImageProvider imageProvider =
                                      snapshot.hasData
                                          ? snapshot.data!
                                          : const AssetImage(
                                              'assets/placeholder.png');
                                  return BlocBuilder<EpisodePlaybackCubit,
                                      EpisodeEntity?>(
                                    builder: (context,
                                        currentlyPlayingEpisodeState) {
                                      final isCurrentlyPlaying =
                                          currentlyPlayingEpisodeState?.eId ==
                                              episode.eId;
                                      return Card(
                                        key: ValueKey(episode.eId),
                                        color: themeData
                                            .colorScheme.primaryContainer,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            side: isCurrentlyPlaying
                                                ? BorderSide(
                                                    color: themeData
                                                        .colorScheme.secondary,
                                                    width: 2.0,
                                                  )
                                                : BorderSide.none),
                                        elevation: 5.0,
                                        shadowColor: Colors.black,
                                        margin: const EdgeInsets.all(8.0),
                                        clipBehavior: Clip.antiAlias,
                                        child: SizedBox(
                                          height: dimension,
                                          child: InkWell(
                                            splashColor: Colors.black87,
                                            onTap: () {
                                              _navigateToEpisodeDetails(
                                                  context, episode, podcast);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildEpisodeImage(
                                                  episode,
                                                  imageProvider,
                                                  isCurrentlyPlaying,
                                                  currentlyPlayingEpisodeState,
                                                  themeData,
                                                  dimension,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              150,
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          _buildEpisodeDetails(
                                                              themeData,
                                                              episode),
                                                          IconButton(
                                                            onPressed: () =>
                                                                _showEpisodeActionsDialog(
                                                                    context,
                                                                    episode),
                                                            icon: const Icon(
                                                              Icons
                                                                  .more_horiz_rounded,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    _buildEpisodeUserActions(
                                                        context, episode),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                });
                          });
                    }).toList(),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildEpisodeImage(
      EpisodeEntity episode,
      ImageProvider imageProvider,
      bool isCurrentlyPlaying,
      EpisodeEntity? currentlyPlayingEpisode,
      ThemeData themeData,
      double dimension) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Stack(
        children: [
          Container(
            width: dimension,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          StreamBuilder<Duration>(
            stream: getIt<MyAudioHandler>().player.positionStream,
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  isCurrentlyPlaying &&
                  currentlyPlayingEpisode != null) {
                final currentDuration = snapshot.data!;
                final totalDuration =
                    Duration(seconds: currentlyPlayingEpisode.duration!);
                final progress = currentDuration.inMilliseconds /
                    totalDuration.inMilliseconds;
                return Positioned(
                  top: 0,
                  left: 0,
                  child: SizedBox(
                    height: dimension,
                    width: dimension,
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      color: themeData.colorScheme.secondary
                          .withValues(alpha: 0.4),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                );
              } else {
                return Positioned(
                  top: 0,
                  left: 0,
                  child: SizedBox(
                    height: dimension,
                    width: dimension,
                    child: LinearProgressIndicator(
                      value: (episode.position.toDouble() /
                              episode.duration!.toDouble())
                          .clamp(0.0, 1.0),
                      color: themeData.colorScheme.secondary
                          .withValues(alpha: 0.4),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeDetails(ThemeData themeData, EpisodeEntity episode) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          6.0,
          10.0,
          8.0,
          10.0,
        ),
        child: SizedBox(
          height: 62.0,
          child: Column(
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
              Text(
                formatTimestamp(
                  episode.datePublished,
                ),
                style: themeData.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodeUserActions(BuildContext context, EpisodeEntity episode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 160,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 40,
          children: [
            Icon(
              episode.read ? Icons.check_rounded : null,
              size: 30.0,
              color: Theme.of(context).colorScheme.primary,
            ),
            const Spacer(),
            Icon(
              Icons.save_alt_rounded,
              size: 30.0,
              color: episode.filePath != null
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white12,
            ),
          ],
        ),
      ),
    );
  }

  void _performAction(
      dynamic value, BuildContext context, EpisodeEntity episode) {

    // Check if episode is already in db. If not, we need to add it
    int id = episode.id != 0 ? episode.id : episodeBox.put(episode);
    // Then we get the episode from db so it can be updated in there
    EpisodeEntity episodeToUpdate = episodeBox.get(id)!;

    episodeToUpdate.favorite = !value;
    episodeBox.put(episodeToUpdate);
  }

  void _showEpisodeActionsDialog(BuildContext context, EpisodeEntity episode) {
    final List<Map<String, dynamic>> menuItems = [
      {
        "title": episode.favorite ? "Unmark as favorite" : "Mark as favorite",
        "onPressed": () {
          final bool isFavorite = episode.favorite;
          _performAction(isFavorite, context, episode);
          Navigator.pop(context);
        }
      },
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var menuItem in menuItems)
                TextButton(
                  onPressed: () => menuItem["onPressed"](),
                  child: Text(menuItem["title"]),
                ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToEpisodeDetails(
      BuildContext context, EpisodeEntity episode, PodcastEntity podcast) {
    Navigator.push(
      context,
      ScaleRoute(
        page: EpisodeDetailsPage(
          episode: episode,
          podcast: podcast,
        ),
      ),
    );
  }
}
