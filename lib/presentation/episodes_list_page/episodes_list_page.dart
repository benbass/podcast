import 'dart:io';

import 'package:flutter/material.dart';

import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/episode_card.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/repositories/episode_repository.dart';
import '../../helpers/core/get_android_version.dart';
import '../../injection.dart';
import 'widgets/row_icon_buttons_episodes.dart';

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
        title: Text("${widget.podcast.title} (${podcastItems.length})",
        softWrap: true,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,),
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
                  const SliverPadding(
                    sliver: SliverToBoxAdapter(
                      child: RowIconButtonsEpisodes(),
                    ),
                    padding: EdgeInsets.only(
                        bottom: 20.0,)
                  ),
                  SliverList.builder(
                    itemCount: podcastItems.length,
                    itemBuilder: (context, index) {
                      final item = podcastItems[index];
                      return EpisodeCard(item: item, widget: widget);
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
