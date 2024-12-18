import 'package:flutter/material.dart';
import 'package:podcast/presentation/custom_widgets/page_transition.dart';

import '../../domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/episodes_list_page/episodes_list_page.dart';

import '../custom_widgets/flexible_space.dart';

class PodcastDetailsPage extends StatelessWidget {
  final PodcastEntity podcast;

  const PodcastDetailsPage({
    super.key,
    required this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            FlexibleSpace(
              podcast: podcast,
              episode: null,
              title: podcast.title,
            ),
            SliverPadding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 10.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...podcast.categories.values.map((value) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          )),
                    ],
                  ),
                )),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 10.0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          podcast.episodeCount.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              SlideRightRoute(
                                page: PodcastEpisodesPage(
                                  podcast: podcast,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.view_list_rounded,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        // subscribe to podcast
                      },
                      icon: const Icon(
                        Icons.subscriptions_rounded,
                        size: 30,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // share podcast link
                      },
                      icon: const Icon(
                        Icons.share_rounded,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  podcast.description,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 100.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      podcast.author,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        podcast.language.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
