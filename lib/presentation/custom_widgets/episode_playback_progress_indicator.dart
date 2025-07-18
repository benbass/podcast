import 'package:flutter/material.dart';

import '../../domain/entities/episode_entity.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';

class EpisodePlaybackProgressIndicator extends StatelessWidget {
  final ThemeData themeData;
  final EpisodeEntity episode;
  final EpisodeEntity? currentlyPlayingEpisode;
  final double? paddingHoriz;
  final double? paddingVert;
  final double? dimension;
  final double? strokeWidth;
  const EpisodePlaybackProgressIndicator({
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
    return Container(
      padding: EdgeInsets.only(
          bottom: paddingVert ?? 4.0, left: paddingHoriz ?? 4.0),
      height: dimension ?? 36,
      width: dimension ?? 36,
      child: StreamBuilder<Duration>(
        stream: getIt<MyAudioHandler>().player.positionStream,
        builder: (context, snapshot) {
          double progress = _calculateProgress(snapshot);
          Color backgroundColor = _getBackgroundColor(progress);
          return CircularProgressIndicator(
            strokeWidth: strokeWidth ?? 3.0,
            strokeCap: StrokeCap.round,
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
      return themeData.colorScheme.secondary.withValues(alpha: 0.6);
    }
    return Colors.transparent;
  }
}
