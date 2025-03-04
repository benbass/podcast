import 'package:flutter/material.dart';

import '../../../domain/entities/episode_entity.dart';
import '../../../domain/entities/podcast_entity.dart';
import '../../audioplayer_overlays/audioplayer_overlays.dart';
import '../../custom_widgets/page_transition.dart';
import '../../episode_details_page/episode_details_page.dart';

class EpisodeInfoButton extends StatelessWidget {
  const EpisodeInfoButton({
    super.key,
    required this.episode,
    required this.podcast,
  });

  final EpisodeEntity episode;
  final PodcastEntity podcast;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        removeOverlay();
        Navigator.of(context).push(
          SizeRoute(
            page: EpisodeDetailsPage(
              episode: episode,
              podcastTitle: podcast.title,
            ),
          ),
        );
      },
      iconSize: 26.0,
      padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
      constraints:
      const BoxConstraints(), // override default min size of 48px
      style: const ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: const Icon(Icons.info_outline_rounded),
    );
  }
}