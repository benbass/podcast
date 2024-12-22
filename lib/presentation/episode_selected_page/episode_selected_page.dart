import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/episode_selected_page/widgets/episode_metadata.dart';
import 'package:podcast/presentation/episode_selected_page/widgets/podcast_website_link.dart';
import 'package:podcast/presentation/episode_selected_page/widgets/episode_info_button.dart';

import '../../domain/entities/episode_entity.dart';
import '../../helpers/core/image_provider.dart';
import '../custom_widgets/play_button.dart';

class EpisodeSelectedPage extends StatelessWidget {
  final EpisodeEntity episode;
  final PodcastEntity podcast;
  const EpisodeSelectedPage({
    super.key,
    required this.episode,
    required this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider img = MyImageProvider(url: episode.image).imageProvider;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          podcast.title,
          maxLines: 3,
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 120,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: img,
                fit: BoxFit.fitWidth,
              ),
            ),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                  ),
                ),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: img,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: EpisodeMetadata(episode: episode),
                            ),
                          ],
                        ),
                        PlayButton(episode: episode, title: podcast.title),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 120),
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                Text(
                  episode.title,
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: EpisodeInfoButton(
                    episode: episode,
                    podcast: podcast,
                  ),
                ),
                const SizedBox(height: 16.0,),
                Visibility(
                  visible: episode.episodeNr != 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${episode.episodeNr}/${podcast.episodeCount}"),
                        const SizedBox(height: 16.0,),
                      ],
                    )
                ),
                Visibility(
                  visible:
                      podcast.link.isNotEmpty && podcast.link.contains('://'),
                  child: PodcastWebsiteLink(podcast: podcast),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
