import 'package:flutter/material.dart';
import 'package:podcast/helpers/notifications/utilities_notifications.dart';
import '../../../domain/entities/episode_entity.dart';
import '../../../helpers/core/utilities/format_utilities.dart';
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
      stream: getIt<MyAudioHandler>().player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final Duration totalDuration =
        Duration(seconds: episode.duration ?? 0);
        final Duration remainingDuration = totalDuration - position;
        String formattedRemainingDuration =
        FormatUtilities.remainingDurationFormatted(remainingDuration);
        return Column(
          children: [
            Slider(
              activeColor: Theme.of(context).colorScheme.onPrimary,
              inactiveColor: Theme.of(context).colorScheme.primary,
              value: position.inSeconds.toDouble(),
              min: 0.0,
              max: getIt<MyAudioHandler>()
                  .player
                  .duration
                  ?.inSeconds
                  .toDouble() ??
                  0.0,
              onChanged: (value)
              {
                final bool playerState = getIt<MyAudioHandler>().player.playing;
                UtilitiesNotifications.cancelNotificationPlayback();
                      getIt<MyAudioHandler>()
                          .player
                          .seek(Duration(seconds: value.toInt()));
                UtilitiesNotifications.createNotificationPlayback(context, playerState, value.toInt());
                    }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    FormatUtilities.durationWithMillisecondsRemovedFormatted(position),
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