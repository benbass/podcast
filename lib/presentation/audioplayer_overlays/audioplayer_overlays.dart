import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/presentation/custom_widgets/page_transition.dart';

import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';
import '../episode_details_page/episode_details_page.dart';

OverlayEntry? overlayEntry;
OverlayState? overlayState;
void showOverlayPlayerMin(
    BuildContext context, EpisodeEntity episode, String title) async {
  overlayState = Overlay.of(context);
  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: MediaQuery.of(context).padding.bottom,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 80,
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  removeOverlay();
                  Navigator.of(context).push(
                    ScaleRoute(
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
                    FadeInImage(
                      fadeOutDuration: const Duration(milliseconds: 100),
                      fadeInDuration: const Duration(milliseconds: 200),
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/placeholder.png",
                          fit: BoxFit.contain,
                          height: 80,
                        );
                      },
                      height: 80,
                      width: 80,
                      fit: BoxFit.scaleDown,
                      placeholder: const AssetImage('assets/placeholder.png'),
                      image: Image.network(
                        episode.image,
                      ).image,
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
                          stream: sl<MyAudioHandler>().player.positionStream,
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
                              return Text('Error: ${snapshot.error}');
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
                  stream: sl<MyAudioHandler>().player.playerStateStream,
                  builder: (context, stream) {
                    final isPlaying = stream.data?.playing;
                    return IconButton(
                      onPressed: () {
                        sl<MyAudioHandler>().handlePlayPause();
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
      ),
    ),
  );

  overlayState!.insert(overlayEntry!);
}

void showOverlayError(BuildContext context, String message) async {
  overlayState = Overlay.of(context);
  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: MediaQuery.of(context).padding.bottom,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 40,
          color: Colors.black,
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Text(
              message,
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    ),
  );

  overlayState!.insert(overlayEntry!);
  Future.delayed(const Duration(seconds: 5), () {
    overlayEntry?.remove();
  });
}

void removeOverlay() async {
  overlayEntry?.remove();
  overlayEntry = null;
}
