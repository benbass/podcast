import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/core/globals.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';

import '../../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../../application/podcast_bloc/podcast_bloc.dart';
import '../../../domain/entities/episode_entity.dart';
import '../../../helpers/core/format_pubdate_string.dart';
import '../../../helpers/core/image_provider.dart';
import '../../../helpers/player/audiohandler.dart';
import '../../../injection.dart';
import '../../custom_widgets/page_transition.dart';
import '../../episode_details_page/episode_details_page.dart';

class EpisodeCard extends StatelessWidget {
  const EpisodeCard({
    super.key,
    required this.episode,
    required this.podcast,
  });

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
          return BlocBuilder<EpisodePlaybackCubit, EpisodeEntity?>(
            builder: (context, currentlyPlayingEpisodeState) {
              final isCurrentlyPlaying =
                  currentlyPlayingEpisodeState?.eId == episode.eId;
              return Card(
                key: ValueKey(episode.eId),
                color: themeData.colorScheme.primaryContainer,
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
                margin: const EdgeInsets.all(8.0),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: dimension,
                  child: InkWell(
                    splashColor: Colors.black87,
                    onTap: () => _navigateToEpisodeDetails(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEpisodeImage(
                          imageProvider,
                          isCurrentlyPlaying,
                          currentlyPlayingEpisodeState,
                          themeData,
                          dimension,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 150,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildEpisodeDetails(themeData),
                                  IconButton(
                                    onPressed: () =>
                                        _showEpisodeActionsDialog(context),
                                    icon: const Icon(
                                      Icons.more_horiz_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildEpisodeUserActions(context),
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
  }

  void _navigateToEpisodeDetails(BuildContext context) {
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

  Widget _buildEpisodeImage(
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

  Widget _buildEpisodeDetails(ThemeData themeData) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          6.0,
          10.0,
          8.0,
          10.0,
        ),
        child: SizedBox(
          height: podcast.subscribed ? 62.0 : 62.0,
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

  Widget _buildEpisodeUserActions(BuildContext context) {
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
              episode.favorite ? Icons.star_rounded : Icons.star_border_rounded,
              size: 30.0,
              color: episode.favorite
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white12,
            ),
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

  void _performAction(String flag, dynamic value, BuildContext context) {
    final podcastBloc = BlocProvider.of<PodcastBloc>(context);

    // Check if episode is already in db. If not, we need to add it
    int id = episode.id != 0 ? episode.id : episodeBox.put(episode);
    // Then we get the episode from db so it can be updated in there
    EpisodeEntity episodeToUpdate = episodeBox.get(id)!;

    /*
    List episodeList = episodeBox.getAll();
    for (var episode in episodeList) {
      if (episode.favorite == true) {
        print(episode.title);
        if (episode.title == "Klaas hat keine Lust mehr") {
          episodeBox.remove(episode.id);
        }
      }
    }
    */

    switch (flag) {
      case "favorite":
        episodeToUpdate.favorite = !value;
        episodeBox.put(episodeToUpdate);
        if (!podcast.subscribed) {
          // This is not needed when podcast is subscribed because that stream updates automatically
          // Stream for not subscribed podcast needs bloc for updates
          podcastBloc.add(
            ToggleEpisodesIconsAfterActionEvent(someBool: value),
          );
        }
        break;
      case "read":
        episodeToUpdate.read = !value;
        episodeBox.put(episodeToUpdate);
        break;
      case "download":
        break;
      case "share":
        break;
      default:
    }
  }

  void _showEpisodeActionsDialog(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        "title": episode.favorite ? "Unmark as favorite" : "Mark as favorite",
        "onPressed": () {
          final bool isFavorite = episode.favorite;
          _performAction("favorite", isFavorite, context);
          Navigator.pop(context);
        }
      },
      if (podcast.subscribed)
        {
          "title": episode.read ? "unmark as read" : "Mark as read",
          "onPressed": () {
            final bool isRead = episode.read;
            _performAction("read", isRead, context);
            Navigator.pop(context);
          }
        },
      {"title": "Download", "onPressed": () {}},
      {"title": "Share", "onPressed": () {}}
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
}
