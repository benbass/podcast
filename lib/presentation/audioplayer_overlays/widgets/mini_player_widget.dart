import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:podcast/core/navigation/app_navigator.dart';

import '../../../application/playback_cubit/playback_cubit.dart';
import '../../../helpers/core/utilities/image_provider.dart';
import '../../../helpers/player/audiohandler.dart';
import '../../../injection.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({
    super.key,
  });

  final double kPlayerHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackCubit, PlaybackState>(
  builder: (context, playbackState) {
    if (playbackState.episode == null){
      return const SizedBox.shrink();
    }
    final episode = playbackState.episode;
    final podcast = episode!.podcast.target;
    return Material(
      color: Colors.transparent,
      child: Container(
        height: kPlayerHeight,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
          color: Colors.white12,
          boxShadow: [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 2.0,
              offset: Offset(0, 2),
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                AppNavigator.navigateToEpisodeDetailsFromGlobalAction();
              },
              // set HitTestBehavior.opaque to enable the GestureDetector to receive events on the entire row and not only on the row's children
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  FutureBuilder<ImageProvider>(
                      future: MyImageProvider(
                              url: episode.image.isNotEmpty
                                  ? episode.image
                                  : podcast!.artworkFilePath != null
                                      ? podcast.artworkFilePath!
                                      : podcast.artwork)
                          .imageProvider,
                      builder: (BuildContext context,
                          AsyncSnapshot<ImageProvider> snapshot) {
                        final ImageProvider imageProvider = snapshot.hasData
                            ? snapshot.data!
                            : const AssetImage('assets/placeholder.png');
                        return Container(
                          height: kPlayerHeight,
                          width: kPlayerHeight,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(10.0)),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        );
                      }),
                  const SizedBox(
                    width: 4,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                        child: Text(
                          podcast!.title,
                        ),
                      ),
                      StreamBuilder<Duration>(
                        stream: getIt<MyAudioHandler>().player.positionStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final currentDuration = snapshot.data!;
                            final totalDuration =
                                Duration(seconds: episode.duration!);
                            final progress = currentDuration.inMilliseconds /
                                totalDuration.inMilliseconds;
                            return SizedBox(
                              height: 6,
                              width: MediaQuery.of(context).size.width - 150,
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                backgroundColor: const Color(0xFFCBD4C2),
                                color: Theme.of(context).colorScheme.secondary,
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
                        width: MediaQuery.of(context).size.width - 150,
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
                stream: getIt<MyAudioHandler>().player.playerStateStream,
                builder: (context, stream) {
                  final isPlaying = stream.data?.playing;
                  return IconButton(
                    onPressed: () {
                      getIt<MyAudioHandler>().handlePlayPause();
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
  },
);
  }
}
