import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/webview.dart';

import '../application/podcast_episode_url/current_url_cubit.dart';
import '../domain/entities/episode_entity.dart';
import '../helpers/core/format_duration.dart';
import '../helpers/core/format_pubdate_string.dart';
import '../helpers/player/audiohandler.dart';
import '../injection.dart';
import 'audioplayer_overlay.dart';

class PodcastSelectedEpisodePage extends StatelessWidget {
  final EpisodeEntity episode;
  final PodcastEntity podcast;
  const PodcastSelectedEpisodePage({
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
            //color: Colors.black54,
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
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                //blendMode: BlendMode.lighten,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        FadeInImage(
                          fadeOutDuration: const Duration(milliseconds: 100),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatTimestamp(episode.datePublished),
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                episode.duration! == 0
                                    ? ""
                                    : formatIntDuration(episode.duration!),
                                style: const TextStyle(color: Colors.black),
                              ),
                              const Spacer(),
                              Icon(
                                episode.read == true
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.remove_circle_outline_rounded,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    BlocBuilder<CurrentUrlCubit, String>(
                      builder: (context, state) {
                        if (state != episode.enclosureUrl) {
                          return StreamBuilder<PlayerState>(
                              stream:
                                  sl<MyAudioHandler>().player.playerStateStream,
                              builder: (context, stream) {
                                final isPlaying = stream.data?.playing;

                                return IconButton(
                                  onPressed: () async {
                                    if (isPlaying == true) {
                                      // Only if player is playing we have an overlay (from current playback) that we can remove
                                      removeOverlay();
                                    }

                                    // source error?
                                    try {
                                      await sl<MyAudioHandler>()
                                          .player
                                          .setUrl(episode.enclosureUrl);
                                      sl<MyAudioHandler>().play();

                                      // We need to wait for the previous overlayEntry, if any, to be removed before we can insert the new one
                                      Future.delayed(
                                          const Duration(seconds: 2));
                                      if (context.mounted) {
                                        BlocProvider.of<CurrentUrlCubit>(
                                                context)
                                            .setCurrentEpisodeUrl(
                                                episode.enclosureUrl);
                                        showOverlayPlayerMin(
                                            context, episode, podcast.title);
                                      }
                                    } on PlayerException {
                                      if (context.mounted) {
                                        showOverlayError(context,
                                            "Error: No valid file exists under the requested url.");
                                      }
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 80,
                                  ),
                                );
                              });
                        } else {
                          return const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white24,
                            size: 80,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
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
                  Text(episode.title),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(episode.episodeNr != 0
                      ? "${episode.episodeNr}/${podcast.episodeCount}"
                      : ""),
                  const SizedBox(
                    height: 8,
                  ),
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
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
