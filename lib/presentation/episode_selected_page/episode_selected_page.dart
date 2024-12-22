import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/custom_widgets/webview.dart';

import '../../domain/entities/episode_entity.dart';
import '../../helpers/core/format_duration.dart';
import '../../helpers/core/format_pubdate_string.dart';
import '../audioplayer_overlays/audioplayer_overlays.dart';
import '../custom_widgets/page_transition.dart';
import '../custom_widgets/play_button.dart';
import '../episode_details_page/episode_details_page.dart';

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
            decoration: BoxDecoration(
              image: DecorationImage(
                image: episode.image != ""
                    ? FadeInImage(
                        fadeOutDuration: const Duration(milliseconds: 100),
                        fadeInDuration: const Duration(milliseconds: 200),
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "assets/placeholder.png",
                            fit: BoxFit.contain,
                            height: 56,
                          );
                        },
                        height: 56,
                        width: 56,
                        fit: BoxFit.scaleDown,
                        placeholder: const AssetImage('assets/placeholder.png'),
                        image: Image.network(
                          episode.image,
                        ).image,
                      ).image
                    : const AssetImage("assets/placeholder.png"),
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
                    //blendMode: BlendMode.lighten,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            FadeInImage(
                              fadeOutDuration:
                                  const Duration(milliseconds: 100),
                              fadeInDuration: const Duration(milliseconds: 200),
                              imageErrorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  "assets/placeholder.png",
                                  fit: BoxFit.cover,
                                  height: 120,
                                );
                              },
                              height: 120,
                              fit: BoxFit.cover,
                              placeholder:
                                  const AssetImage('assets/placeholder.png'),
                              image: Image.network(
                                episode.image,
                              ).image,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formatTimestamp(episode.datePublished),
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    episode.duration! == 0
                                        ? ""
                                        : formatIntDuration(episode.duration!),
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    episode.read == true
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.remove_circle_outline_rounded,
                                    //color: Colors.black,
                                  ),
                                ],
                              ),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    episode.title,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      removeOverlay();
                      Navigator.of(context).push(
                        ScaleRoute(
                          page: EpisodeDetailsPage(
                            episode: episode,
                            title: podcast.title,
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
                  ),
                  Text(episode.episodeNr != 0
                      ? "${episode.episodeNr}/${podcast.episodeCount}"
                      : ""),
                  podcast.link.isNotEmpty && podcast.link.contains('://')
                      ? GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MyWebView(
                                  url: podcast.link,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "Podcast website",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


