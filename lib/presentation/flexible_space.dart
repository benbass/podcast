import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';

import '../helpers/player/audiohandler.dart';
import '../injection.dart';
import 'audioplayer_overlay.dart';

class FlexibleSpace extends StatelessWidget {
  final PodcastEntity? podcast;
  final EpisodeEntity? episode;
  final String title;

  const FlexibleSpace({
    super.key,
    required this.podcast,
    required this.episode,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    String image = "";

    if (episode != null) {
      image = episode!.image;
    } else if (podcast != null) {
      image = podcast!.artwork;
    }

    return SliverAppBar(
      collapsedHeight: 90,
      expandedHeight: MediaQuery.of(context).size.height / 3,
      pinned: true,
      leading: null,
      automaticallyImplyLeading:
          false, // we remove the default back-button, together with leading: null
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.only(
            bottom: 70,
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: image != ""
                        ? NetworkImage(image)
                        : const AssetImage("assets/placeholder.png"),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Center(
                      child: FadeInImage(
                        fadeOutDuration: const Duration(milliseconds: 100),
                        fadeInDuration: const Duration(milliseconds: 200),
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "assets/placeholder.png",
                            fit: BoxFit.cover,
                            //height: 300,
                            //width: 300,
                          );
                        },
                        //height: 300,
                        //width: 300,
                        fit: BoxFit.cover,
                        placeholder: const AssetImage('assets/placeholder.png'),
                        image: NetworkImage(image),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4.0),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                ),
              ),
            ],
          ),
        ),
        titlePadding: const EdgeInsets.all(4.0),
        expandedTitleScale: 1.5,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            IconButton(
              onPressed: () {
                if (episode != null) {
                  if (sl<MyAudioHandler>().player.processingState ==
                          ProcessingState.ready &&
                      overlayEntry == null) {
                    showOverlayPlayerMin(context, episode!, title);
                  }
                }
                Navigator.of(context).pop();
              },
              icon: const BackButtonIcon(),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 14,
                    ),
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
