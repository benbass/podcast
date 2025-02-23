import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/custom_widgets/elevated_button_subscribe.dart';

import '../../helpers/core/image_provider.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';
import '../audioplayer_overlays/audioplayer_overlays.dart';

/// This widget is used to show some details about the selected podcast or episode, depending on corresponding variable being null or not.
class FlexibleSpace extends StatelessWidget {
  final PodcastEntity? podcast; // if null, widget is used for episode
  final EpisodeEntity? episode; // if null, widget is used for podcast
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

    ImageProvider img = MyImageProvider(url: image).imageProvider;

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
                    image: img,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: img,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
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
              if(podcast != null)
                Positioned(
                top: 12,
                right: 12,
                child: ElevatedButtonSubscribe(podcast: podcast!, navigate: false,),
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
                  if (getItI<MyAudioHandler>().player.processingState ==
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
