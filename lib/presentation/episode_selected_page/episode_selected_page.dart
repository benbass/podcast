import 'package:flutter/material.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/episode_selected_page/widgets/blurred_image_background.dart';
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
    return FutureBuilder<ImageProvider>(
        future: MyImageProvider(url: podcast.artwork).imageProvider,
        builder: (BuildContext context, AsyncSnapshot<ImageProvider> snapshot) {
          final ImageProvider imageProvider = snapshot.hasData
              ? snapshot.data!
              : const AssetImage('assets/placeholder.png');
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(
                  podcast.title,
                  maxLines: 3,
                ),
              ),
              SliverToBoxAdapter(
                child: BlurredImageBackground(
                  image: imageProvider,
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
                                image: imageProvider,
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
                      PlayButton(
                        episode: episode,
                        title: podcast.title,
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      episode.title,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          /// TODO
                          // Mark or unmark this episode as favorite:
                          // save status to DB + update state of icon in widget EpisodeMetadata
                        },
                        iconSize: 26.0,
                        padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
                        constraints:
                        const BoxConstraints(),
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(
                          Icons.favorite,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: EpisodeInfoButton(
                        episode: episode,
                        podcast: podcast,
                      ),
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    if (episode.episodeNr != 0) ...[
                      Text("${episode.episodeNr}/${podcast.episodeCount}"),
                      const SizedBox(height: 16.0),
                    ],
                    if (podcast.link.isNotEmpty && podcast.link.contains('://'))
                      PodcastWebsiteLink(podcast: podcast),
                  ]),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
