import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/core/globals.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';

import '../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../application/episodes_cubit/episodes_cubit.dart';
import '../../domain/entities/episode_entity.dart';
import '../../helpers/core/format_pubdate_string.dart';
import '../../helpers/core/image_provider.dart';
import 'action_feedback/action_feedback.dart';
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
    //episode.id != 0 ? episodeBox.get(episode.id) : episode;
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
                //margin: const EdgeInsets.all(8.0),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: dimension,
                  width: MediaQuery.of(context).size.width,
                  child: InkWell(
                    splashColor: Colors.black87,
                    onTap: () => _navigateToEpisodeDetails(context),
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
                                    child: _buildEpisodeDetails(themeData),
                                  ),
                                  const SizedBox(
                                    width: 40,
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _showEpisodeActionsDialog(context),
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
                                    episode: episode,
                                    isCurrentlyPlaying: isCurrentlyPlaying,
                                    currentlyPlayingEpisode:
                                        currentlyPlayingEpisodeState,
                                  ),
                                  if (episode.isSubscribed)
                                    _buildEpisodeIconsRow(context),
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
          formatTimestamp(
            episode.datePublished,
          ),
          style: themeData.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildEpisodeIconsRow(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 40,
        children: [
          const Spacer(),
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
    );
  }

  void _performAction(
    String flag,
    dynamic value,
    BuildContext context,
  ) {
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
    // We delete episode from db if it doesn't belong to any subscribed podcasts and all flag values are reset to initial
    void deleteEpisodeFromDb() {
      // Get the latest episode version from db since we just changed a flag value
      final episodeDb = episodeBox.get(episode.id)!;
      if ((episode.isSubscribed == false) &
      (episodeDb.favorite == false) &
      (episodeDb.filePath == null) &
      (episodeDb.position == 0)) {
        episodeBox.remove(episode.id);
      }
      if((episode.isSubscribed == false) &
      (episodeDb.favorite == true) ||
      (episodeDb.filePath != null) ||
      (episodeDb.position != 0)){
        final episodes = BlocProvider.of<EpisodesCubit>(context).state;
        if (episodes.isNotEmpty) {
          int index = episodes.indexWhere((element) => element.eId == episode.eId);
          episodes.insert(index, episodeDb);
          episodes.removeAt(index+1);
          BlocProvider.of<EpisodesCubit>(context).setEpisodes(episodes);
        }
      }

    }

    switch (flag) {
      case "favorite":
        episode.favorite = !value;
        episodeBox.put(episode);
        deleteEpisodeFromDb();
        break;
      case "read":
        episode.read = !value;
        episodeBox.put(episode);
        deleteEpisodeFromDb();
        break;
      case "download":
        //episode.filePath = value;
        //episodeBox.put(episode);
        //deleteEpisodeFromDb();
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
          ActionFeedback.show(context, episode.favorite ? Icons.star : Icons.star_border);
        }
      },
      if (episode.isSubscribed)
        {
          "title": episode.read ? "unmark as read" : "Mark as read",
          "onPressed": () {
            final bool isRead = episode.read;
            _performAction("read", isRead, context);
            Navigator.pop(context);
            ActionFeedback.show(context, episode.read ? Icons.check : Icons.radio_button_unchecked);
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
