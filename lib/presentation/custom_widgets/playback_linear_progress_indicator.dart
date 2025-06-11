import 'package:flutter/material.dart';

import '../../domain/entities/episode_entity.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';

class PlaybackLinearProgressIndicator extends StatelessWidget {
  final ThemeData themeData;
  final EpisodeEntity episode;
  final EpisodeEntity? currentlyPlayingEpisode;
  final double? paddingHoriz;
  final double? paddingVert;
  final double? dimension;
  final double? strokeWidth;
  const PlaybackLinearProgressIndicator({
    super.key,
    required this.themeData,
    required this.episode,
    required this.currentlyPlayingEpisode,
    this.paddingHoriz,
    this.paddingVert,
    this.dimension,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    double width = 0.0;
    if(dimension != null){
      width = dimension! - 8.0; // 8.0 is the horizontal padding
    } else {
      width = MediaQuery.of(context).size.width;
    }
    return Container(
      padding: EdgeInsets.only(
          bottom: paddingVert ?? 2.0, left: paddingHoriz ?? 4.0),
      height: 6,
      width: width,
      child: StreamBuilder<Duration>(
        stream: getIt<MyAudioHandler>().player.positionStream,
        builder: (context, snapshot) {
          double progress = _calculateProgress(snapshot);
          Color backgroundColor = _getBackgroundColor(progress);
          return LinearProgressIndicator(
            value: progress,
            color: themeData.colorScheme.primary.withValues(alpha: 0.6),
            backgroundColor: backgroundColor,
          );
        },
      ),
    );
  }

  double _calculateProgress(AsyncSnapshot<Duration> snapshot) {
    if (snapshot.hasData &&
        currentlyPlayingEpisode != null &&
        currentlyPlayingEpisode!.eId == episode.eId) {
      final currentPosition = snapshot.data!;
      final totalDuration =
      Duration(seconds: currentlyPlayingEpisode!.duration!);
      return (currentPosition.inMilliseconds / totalDuration.inMilliseconds)
          .clamp(0.0, 1.0);
    } else if (episode.duration != null && episode.duration! > 0) {
      return (episode.position / episode.duration!).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  Color _getBackgroundColor(double progress) {
    if (progress > 0 ||
        (episode.position > 0 &&
            episode.duration != null &&
            episode.duration! > 0)) {
      return themeData.colorScheme.secondary.withValues(alpha: 0.9);
    }
    return Colors.transparent;
  }
}
