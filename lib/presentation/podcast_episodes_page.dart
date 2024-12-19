import 'dart:io';

import 'package:flutter/material.dart';

import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/page_transition.dart';
import 'package:podcast/presentation/podcast_selected_episode_page.dart';
import '../domain/entities/episode_entity.dart';
import '../domain/repositories/episode_repository.dart';
import '../helpers/core/format_pubdate_string.dart';
import '../helpers/core/get_android_version.dart';
import '../injection.dart';

class PodcastEpisodesPage extends StatefulWidget {
  final PodcastEntity podcast;

  const PodcastEpisodesPage({
    super.key,
    required this.podcast,
  });

  @override
  State<PodcastEpisodesPage> createState() => _PodcastEpisodesPageState();
}

class _PodcastEpisodesPageState extends State<PodcastEpisodesPage> {
  late List<EpisodeEntity> podcastItems = [];

  getEpisodes() async {
    final List<EpisodeEntity> items = await sl<EpisodeRepository>()
        .fetchEpisodesByFeedId(widget.podcast.id);
    setState(() {
      podcastItems = [...items];
    });
  }

  @override
  void initState() {
    getEpisodes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(widget.podcast.title),
            Row(
              children: [
                const Icon(Icons.list_rounded, size: 30,),
                const SizedBox(
                  width: 8.0,
                ),
                Text(
                  podcastItems.length.toString(),
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<EpisodeEntity>>(
        future:
            sl<EpisodeRepository>().fetchEpisodesByFeedId(widget.podcast.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final podcastItems = snapshot.data!;
            return SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            onPressed: () {
                              // full text search
                            },
                            icon: const Icon(
                              Icons.search_rounded,
                              size: 30,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // activate select on list items
                            },
                            icon: const Icon(
                              Icons.check_rounded,
                              size: 30,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // make a query
                            },
                            icon: const Icon(
                              Icons.refresh_rounded,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.only(
                        bottom: 20.0,)
                  ),
                  SliverList.builder(
                    itemCount: podcastItems.length,
                    itemBuilder: (context, index) {
                      final item = podcastItems[index];
                      return Card(
                        key: ValueKey(item.pId),
                        color: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5.0,
                        shadowColor: Colors.black,
                        margin: const EdgeInsets.all(8.0),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          height: 90.0,
                          child: InkWell(
                            splashColor: Colors.black87,
                            onTap: () async {
                              EpisodeEntity episode = EpisodeEntity(
                                pId: item.pId,
                                title: item.title,
                                description: item.description,
                                guid: item.guid,
                                datePublished: item.datePublished,
                                datePublishedPretty: item.datePublishedPretty,
                                enclosureUrl: item.enclosureUrl,
                                enclosureLength: item.enclosureLength,
                                duration: item.duration,
                                explicit: item.explicit,
                                episodeNr: item.episodeNr,
                                episodeType: item.episodeType,
                                season: item.season,
                                image: item.image,
                                feedUrl: item.feedUrl,
                                link: item.link,
                                feedImage: item.feedImage,
                                feedId: item.feedId,
                                podcastGuid: item.podcastGuid,
                                favorite: item.favorite,
                                read: item.read,
                                completed: item.completed,
                                position: item.position,
                              );
                              Navigator.push(
                                context,
                                ScaleRoute(
                                  page: PodcastSelectedEpisodePage(
                                    episode: episode,
                                    podcast: widget.podcast,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: FadeInImage(
                                    fadeOutDuration:
                                        const Duration(milliseconds: 100),
                                    fadeInDuration:
                                        const Duration(milliseconds: 200),
                                    imageErrorBuilder:
                                        (context, error, stackTrace) {
                                      return Image.asset(
                                        "assets/placeholder.png",
                                        fit: BoxFit.cover,
                                        height: 90.0,
                                      );
                                    },
                                    height: 90.0,
                                    width: 90.0,
                                    fit: BoxFit.cover,
                                    placeholder: const AssetImage(
                                        'assets/placeholder.png'),
                                    image: Image.network(
                                      item.image,
                                    ).image,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      6.0,
                                      10.0,
                                      8.0,
                                      10.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.title,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          maxLines: 2,
                                        ),
                                        Text(
                                          formatTimestamp(
                                            item.datePublished,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 80,
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Fehler: ${snapshot.error}');
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      bottomNavigationBar: Platform.isAndroid && androidVersion > 14
          ? Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              height: MediaQuery.of(context).padding.bottom,
            )
          : null,
    );
  }
}
