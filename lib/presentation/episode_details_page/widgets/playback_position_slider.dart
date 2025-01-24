import 'package:flutter/material.dart';

import '../../../domain/entities/episode_entity.dart';
import '../../../helpers/core/format_duration.dart';
import '../../../helpers/player/audiohandler.dart';
import '../../../injection.dart';

class PlaybackPositionSlider extends StatelessWidget {
  const PlaybackPositionSlider({
    super.key,
    required this.episode,
  });

  final EpisodeEntity episode;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: getItI<MyAudioHandler>().player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final Duration totalDuration =
        Duration(seconds: episode.duration!);
        final Duration remainingDuration = totalDuration - position;
        String formattedRemainingDuration =
        formatRemainingDuration(remainingDuration);
        return Column(
          children: [
            Slider(
              activeColor: Theme.of(context).colorScheme.onPrimary,
              inactiveColor: Theme.of(context).colorScheme.primary,
              value: position.inSeconds.toDouble(),
              min: 0.0,
              max: getItI<MyAudioHandler>()
                  .player
                  .duration
                  ?.inSeconds
                  .toDouble() ??
                  0.0,
              onChanged: (value) => getItI<MyAudioHandler>()
                  .player
                  .seek(Duration(seconds: value.toInt())),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    removeMillisecondsFromDuration(position),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    totalDuration == Duration.zero
                        ? ""
                        : formattedRemainingDuration,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}