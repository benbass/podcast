import 'dart:io';

import 'package:flutter/material.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';

import 'package:podcast/domain/repositories/episode_query_repository.dart';
import 'package:podcast/presentation/page_transition.dart';
import 'package:podcast/presentation/podcast_selected_episode_page.dart';
import '../domain/entities/episode_entity.dart';
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
  bool isLoading = false;

  late List<EpisodeEntity> podcastItems = [];
  late int x = 0;

  getEpisodes() async {
    final List<EpisodeEntity> items = await sl<EpisodeQueryRepository>()
        .getEpisodesOnQuery(widget.podcast.id);
    setState(() {
      podcastItems = [...items];
      isLoading = false;
    });
  }

  @override
  void initState() {
    getEpisodes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('Anzahl der gefundenen Elemente: ${podcastItems.length}');
    for (final item in podcastItems) {
      print('Titel: ${item.title}');
      print('Beschreibung: ${item.description}');
      print('Veröffentlichungsdatum: ${item.datePublishedPretty}');
      print('Dauer: ${item.duration!.toString()}');
      print('Enclosure-URL: ${item.enclosureUrl}');
      print('Image: ${item.image}');
      print('Site Url: ${item.link}');
      print('Episode Type: ${item.episodeType}');
      print('Episode Nr: ${item.episodeNr}');
      print('Explicit: ${item.explicit}');
      print('---');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Episodes in '${widget.podcast.title}'"),
      ),
      body: FutureBuilder<List<EpisodeEntity>>(
        future:
            sl<EpisodeQueryRepository>().getEpisodesOnQuery(widget.podcast.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final podcastItems = snapshot.data!;
            return SafeArea(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 20,
                    ),
                  ),
                  SliverList.builder(
                    itemCount: podcastItems.length,
                    itemBuilder: (context, index) {
                      final item = podcastItems[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: ListTile(
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
                          leading: FadeInImage(
                            fadeOutDuration: const Duration(milliseconds: 100),
                            fadeInDuration: const Duration(milliseconds: 200),
                            imageErrorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                "assets/placeholder.png",
                                fit: BoxFit.contain,
                                height: 102,
                              );
                            },
                            height: 102,
                            // width: 72,
                            fit: BoxFit.fitHeight,
                            placeholder:
                                const AssetImage('assets/placeholder.png'),
                            image: Image.network(
                              item.image,
                            ).image,
                          ),
                          title: Text(item.title),
                          subtitle: Text(formatTimestamp(item.datePublished)),
                          tileColor: Theme.of(context).colorScheme.secondary,
                          //contentPadding: const EdgeInsets.all(6.0),
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
