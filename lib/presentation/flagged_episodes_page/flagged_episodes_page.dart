import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/podcast_bloc/podcast_bloc.dart';
import '../../core/globals.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/usecases/episode_usecases.dart';
import '../../helpers/core/format_pubdate_string.dart';
import '../../injection.dart';

class FlaggedEpisodesPage extends StatelessWidget {
  final String flag;
  const FlaggedEpisodesPage({super.key, required this.flag});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(flag,style: themeData.textTheme.displayLarge!),
      ),
      body: StreamBuilder(
        stream: getIt<EpisodeUseCases>().getFlaggedEpisodes(flag: flag),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
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
                      return Card(
                        key: ValueKey(episode.eId),
                        color: themeData.colorScheme.primaryContainer,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide.none),
                        elevation: 5.0,
                        shadowColor: Colors.black,
                        margin: const EdgeInsets.all(8.0),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          height: 120,
                          child: InkWell(
                            splashColor: Colors.black87,
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width - 150,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildEpisodeDetails(
                                              themeData, episode),
                                          IconButton(
                                            onPressed: () =>
                                                _showEpisodeActionsDialog(
                                                    context, episode),
                                            icon: const Icon(
                                              Icons.more_horiz_rounded,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildEpisodeUserActions(context, episode),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
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

  void _performAction(
      dynamic value, BuildContext context, EpisodeEntity episode) {
    final podcastBloc = BlocProvider.of<PodcastBloc>(context);

    // Check if episode is already in db. If not, we need to add it
    int id = episode.id != 0 ? episode.id : episodeBox.put(episode);
    // Then we get the episode from db so it can be updated in there
    EpisodeEntity episodeToUpdate = episodeBox.get(id)!;

    episodeToUpdate.favorite = !value;
    episodeBox.put(episodeToUpdate);
    podcastBloc.add(
      ToggleEpisodesIconsAfterActionEvent(someBool: value),
    );
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
}
