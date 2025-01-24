import 'package:flutter/material.dart';
import '../../../domain/entities/podcast_entity.dart';
import '../../custom_widgets/page_transition.dart';
import '../../episodes_list_page/episodes_list_page.dart';

class RowIconButtonsPodcasts extends StatelessWidget {
  const RowIconButtonsPodcasts({
    super.key,
    required this.podcast,
  });

  final PodcastEntity podcast;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                    page: Builder(builder: (context) {
                      return EpisodesPage(
                        podcast: podcast,
                      );
                    }),
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
            // share podcast link
          },
          icon: const Icon(
            Icons.share_rounded,
            size: 30,
          ),
        ),
      ],
    );
  }
}
