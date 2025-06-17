import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/custom_widgets/play_button.dart';

import '../../../helpers/core/utilities/image_provider.dart';

class FlexibleSpace extends StatelessWidget {
  final PodcastEntity podcast;
  final EpisodeEntity episode;
  final int? episodeIndex;
  final List<EpisodeEntity>? playlist;
  final String title;
  final String? flag;

  const FlexibleSpace({
    super.key,
    required this.podcast,
    required this.episode,
    this.episodeIndex,
    this.playlist,
    required this.title,
    this.flag,
  });

  @override
  Widget build(BuildContext context) {
    final String imageUrl = _getImageUrl();

    return SliverAppBar(
      primary: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      pinned: false,
      expandedHeight: MediaQuery.of(context).size.height * 0.33,
      collapsedHeight: MediaQuery.of(context).size.height * 0.15,
      floating: true,
      snap: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        collapseMode: CollapseMode.parallax,
        background: Stack(
          children: [
            _buildBackgroundImage(imageUrl),
          ],
        ),
        titlePadding: const EdgeInsets.all(4.0),
        expandedTitleScale: 1.5,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PlayButton(
              episode: episode,
              episodeIndex: episodeIndex!,
              playlist: playlist!,
              podcast: podcast,
            ),
          ],
        ),
      ),
    );
  }

  /// Determines the image URL based on whether an episode or podcast is provided.
  String _getImageUrl() {
    return episode.image.isNotEmpty
        ? episode.image
        : podcast.artworkFilePath != null
            ? podcast.artworkFilePath!
            : podcast.artwork;
  }

  /// Builds the background image with blur effect.
  Widget _buildBackgroundImage(String imageUrl) {
    return FutureBuilder<ImageProvider>(
      future: MyImageProvider(url: imageUrl).imageProvider,
      builder: (BuildContext context, AsyncSnapshot<ImageProvider> snapshot) {
        final ImageProvider imageProvider = snapshot.hasData
            ? snapshot.data!
            : const AssetImage('assets/placeholder.png');

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: podcast.subscribed
                      ? podcast.artworkFilePath != null
                          ? FileImage(File(podcast.artworkFilePath!))
                          : const AssetImage('assets/placeholder.png')
                      : imageProvider,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
