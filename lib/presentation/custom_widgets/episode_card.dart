import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/core/globals.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:uuid/uuid.dart';

import '../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../../domain/entities/episode_entity.dart';
import '../../helpers/core/format_pubdate_string.dart';
import '../../helpers/core/image_provider.dart';
import 'episode_progress_indicator.dart';
import 'page_transition.dart';
import '../episode_details_page/episode_details_page.dart';

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
    // Let's see if episode exists in DB:
    final episodeForCard =
        episode.id != 0 ? episodeBox.get(episode.id) : episode;
    return FutureBuilder<ImageProvider>(
        future: MyImageProvider(
                url: episodeForCard!.image.isNotEmpty
                    ? episodeForCard.image
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
                key: ValueKey(episodeForCard.eId),
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
                //margin: const EdgeInsets.all(8.0),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: dimension,
                  width: MediaQuery.of(context).size.width,
                  child: InkWell(
                    splashColor: Colors.black87,
                    onTap: () =>
                        _navigateToEpisodeDetails(context, episodeForCard),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEpisodeImage(
                          imageProvider,
                          isCurrentlyPlaying,
                          currentlyPlayingEpisodeState,
                          themeData,
                          dimension,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            6.0,
                            10.0,
                            0.0,
                            2.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        minWidth:
                                            MediaQuery.of(context).size.width /
                                                2),
                                    child: _buildEpisodeDetails(
                                        themeData, episodeForCard),
                                  ),
                                  const SizedBox(
                                    width: 40,
                                  ),
                                  IconButton(
                                    onPressed: () => _showEpisodeActionsDialog(
                                        context, episodeForCard),
                                    icon: const Icon(
                                      Icons.more_horiz_rounded,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  EpisodeProgressIndicator(
                                    themeData: themeData,
                                    episode: episodeForCard,
                                    isCurrentlyPlaying: isCurrentlyPlaying,
                                    currentlyPlayingEpisode:
                                        currentlyPlayingEpisodeState,
                                  ),
                                  _buildEpisodeIconsRow(
                                      context, episodeForCard),
                                ],
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
        });
  }

  void _navigateToEpisodeDetails(
      BuildContext context, EpisodeEntity episodeForCard) {
    Navigator.push(
      context,
      ScaleRoute(
        page: EpisodeDetailsPage(
          episode: episodeForCard,
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

  Widget _buildEpisodeDetails(
      ThemeData themeData, EpisodeEntity episodeForCard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          episodeForCard.title,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          maxLines: 2,
          style: themeData.textTheme.displayMedium,
        ),
        Text(
          formatTimestamp(
            episodeForCard.datePublished,
          ),
          style: themeData.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildEpisodeIconsRow(
      BuildContext context, EpisodeEntity episodeForCard) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: BlocListener<PodcastBloc, PodcastState>(
        listenWhen: (previous, current) =>
            (previous.episodeToRefresh != current.episodeToRefresh) &&
            !podcast.subscribed,
        listener: (context, state) {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 40,
          children: [
            const Spacer(),
            Icon(
              episodeForCard.read ? Icons.check_rounded : null,
              size: 30.0,
              color: Theme.of(context).colorScheme.primary,
            ),
            const Spacer(),
            Icon(
              episodeForCard.favorite
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              size: 30.0,
              color: episodeForCard.favorite
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white12,
            ),
            Icon(
              Icons.save_alt_rounded,
              size: 30.0,
              color: episodeForCard.filePath != null
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white12,
            ),
          ],
        ),
      ),
    );
  }

  void _performAction(String flag, dynamic value, BuildContext context,
      EpisodeEntity episodeForCard) {
    final podcastBloc = BlocProvider.of<PodcastBloc>(context);

    // Check if episode is already in db. If not, we need to add it
    int id = episodeForCard.id != 0
        ? episodeForCard.id
        : episodeBox.put(episodeForCard);
    // Then we get the episode from db so it can be updated in there
    EpisodeEntity episodeToUpdate = episodeBox.get(id)!;

/*
// Delete specific episode from db (just for testing)
    List episodeList = episodeBox.getAll();
    for (var episode in episodeList) {
      if (episode.favorite == true) {
        print(episode.title);
        if (episode.title == "...enter title here...") {
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
          // Not needed by subscribed podcasts because icons update
          // automatically when stream data from db changes.
          // This Bloc event is needed only when podcast is not subscribed since
          // stream doesn't change anymore after episodes were fetched from remote.

          // We use a Uuid for each tap so BlocListener always receives a different value
          podcastBloc.add(EpisodeFlagChangedEvent(uid: const Uuid().v4()));
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

  void _showEpisodeActionsDialog(
      BuildContext context, EpisodeEntity episodeForCard) {
    final List<Map<String, dynamic>> menuItems = [
      {
        "title":
            episodeForCard.favorite ? "Unmark as favorite" : "Mark as favorite",
        "onPressed": () {
          final bool isFavorite = episodeForCard.favorite;
          _performAction("favorite", isFavorite, context, episodeForCard);
          Navigator.pop(context);
        }
      },
      //if (podcast.subscribed)
      {
        "title": episodeForCard.read ? "unmark as read" : "Mark as read",
        "onPressed": () {
          final bool isRead = episodeForCard.read;
          _performAction("read", isRead, context, episodeForCard);
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
