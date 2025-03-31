import 'package:flutter/material.dart';

import '../../domain/entities/episode_entity.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';

class EpisodeProgressIndicatorOverlay extends StatelessWidget {
  final ThemeData themeData;
  final EpisodeEntity episode;
  final bool isCurrentlyPlaying;
  final EpisodeEntity? currentlyPlayingEpisode;
  final double overlayHeight;
  final double overlayWidth;
  const EpisodeProgressIndicatorOverlay({
    super.key,
    required this.themeData,
    required this.episode,
    required this.isCurrentlyPlaying,
    required this.overlayHeight,
    required this.overlayWidth,
    required this.currentlyPlayingEpisode,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: getIt<MyAudioHandler>().player.positionStream,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            isCurrentlyPlaying &&
            currentlyPlayingEpisode != null) {
          final currentDuration = snapshot.data!;
          final totalDuration =
              Duration(seconds: currentlyPlayingEpisode!.duration!);
          final progress =
              currentDuration.inMilliseconds / totalDuration.inMilliseconds;
          return Positioned(
            top: 0,
            left: 0,
            child: SizedBox(
              height: overlayHeight,
              width: overlayWidth,
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                color: themeData.colorScheme.secondary.withValues(alpha: 0.4),
                backgroundColor: Colors.transparent,
              ),
            ),
          );
        } else {
          return Positioned(
            top: 0,
            left: 0,
            child: SizedBox(
              height: overlayHeight,
              width: overlayWidth,
              child: LinearProgressIndicator(
                value:
                    (episode.position.toDouble() / episode.duration!.toDouble())
                        .clamp(0.0, 1.0),
                color: themeData.colorScheme.secondary.withValues(alpha: 0.4),
                backgroundColor: Colors.transparent,
              ),
            ),
          );
        }
      },
    );
  }
}
