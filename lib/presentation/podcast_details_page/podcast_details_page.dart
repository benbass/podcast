import 'package:flutter/material.dart';
import 'package:podcast/presentation/podcast_details_page/widgets/categories.dart';
import 'package:podcast/presentation/podcast_details_page/widgets/row_icon_buttons_podcasts.dart';

import '../../domain/entities/podcast_entity.dart';

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
                      ...podcast.categories.values.map((value) => Categories(value: value,)),
                    ],
                  ),
                )),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 10.0),
              sliver: SliverToBoxAdapter(
                child: RowIconButtonsPodcasts(podcast: podcast),
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

