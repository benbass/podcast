import 'package:flutter/material.dart';
import 'package:podcast/presentation/page_transition.dart';

import '../domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/podcast_episodes_page.dart';

import 'flexible_space.dart';

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
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
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
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    TextButton(
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
                      child: const Text('Episodes'),
                    ),
                    TextButton(
                      onPressed: () {
                        // save podcast to db
                      },
                      child: const Text('Follow'),
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
