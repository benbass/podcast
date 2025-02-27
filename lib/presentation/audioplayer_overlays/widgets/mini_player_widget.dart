import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';

import '../../../domain/entities/episode_entity.dart';
import '../../../helpers/core/image_provider.dart';
import '../../../helpers/player/audiohandler.dart';
import '../../../injection.dart';
import '../../custom_widgets/page_transition.dart';
import '../../episode_details_page/episode_details_page.dart';
import '../audioplayer_overlays.dart';

class MiniPlayerWidget extends StatelessWidget {
  final EpisodeEntity episode;
  final String title;
  const MiniPlayerWidget({
    super.key,
    required this.episode,
    required this.title,
  });

  final double kPlayerHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    ImageProvider img = MyImageProvider(url: episode.image).imageProvider;
    return Material(
      color: Colors.transparent,
      child: Container(
        height: kPlayerHeight,
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                removeOverlay();
                Navigator.of(context).push(
                  SlideRouteWithCurve(
                    page: EpisodeDetailsPage(
                      episode: episode,
                      title: title,
                    ),
                  ),
                );
              },
              // set HitTestBehavior.opaque to enable the GestureDetector to receive events on the entire row and not only on the row's children
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                Container(
                height: kPlayerHeight,
                width: kPlayerHeight,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: img,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
                  const SizedBox(
                    width: 4,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: 20,
                        width: MediaQuery.of(context).size.width - 170,
                        child: Text(
                          title,
                        ),
                      ),
                      StreamBuilder<Duration>(
                        stream: getItI<MyAudioHandler>().player.positionStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final currentDuration = snapshot.data!;
                            final totalDuration =
                                Duration(seconds: episode.duration!);
                            final progress = currentDuration.inMilliseconds /
                                totalDuration.inMilliseconds;
                            return SizedBox(
                              height: 6,
                              width: MediaQuery.of(context).size.width - 170,
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                //color: Colors.white,
                                //backgroundColor: Colors.green,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const Icon(Icons.error, color: Colors.red);
                          } else {
                            return const CircularProgressIndicator(); // loading
                          }
                        },
                      ),
                      SizedBox(
                        height: 20,
                        width: MediaQuery.of(context).size.width - 170,
                        child: Marquee(
                          text: episode.title,
                          //style: const TextStyle(color: Colors.white),
                          scrollAxis: Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          blankSpace: 120.0,
                          velocity: 40.0,
                          pauseAfterRound: const Duration(seconds: 3),
                          startPadding: 0.0,
                          accelerationDuration: const Duration(seconds: 1),
                          accelerationCurve: Curves.linear,
                          decelerationDuration:
                              const Duration(milliseconds: 500),
                          decelerationCurve: Curves.easeOut,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            StreamBuilder<PlayerState>(
                stream: getItI<MyAudioHandler>().player.playerStateStream,
                builder: (context, stream) {
                  final isPlaying = stream.data?.playing;
                  return IconButton(
                    onPressed: () {
                      getItI<MyAudioHandler>().handlePlayPause();
                    },
                    icon: Icon(
                      isPlaying == true
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 50,
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
