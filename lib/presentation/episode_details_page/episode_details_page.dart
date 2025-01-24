import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/presentation/episode_details_page/widgets/player_controls.dart';

import '../../helpers/core/format_duration.dart';
import '../../helpers/core/format_pubdate_string.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';
import '../audioplayer_overlays/audioplayer_overlays.dart';
import '../custom_widgets/flexible_space.dart';
import '../custom_widgets/play_button.dart';

class EpisodeDetailsPage extends StatelessWidget {
  final EpisodeEntity episode;
  final String title;

  const EpisodeDetailsPage({
    super.key,
    required this.episode,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    bool isPlayerReady = getItI<MyAudioHandler>().player.processingState == ProcessingState.ready ||
        getItI<MyAudioHandler>().player.playing;

    // We wrap this widget in PopScope so we can apply a method on the OS back-button
    // where we rebuild the overlay!
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        if (getItI<MyAudioHandler>().player.processingState ==
                ProcessingState.ready &&
            overlayEntry == null) {
          showOverlayPlayerMin(context, episode, title);
        }
        // We don't pop immediately (it causes an exception): we use a scheduler
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pop();
        });
      },
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  FlexibleSpace(
                    podcast: null,
                    episode: episode,
                    title: title,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatTimestamp(episode.datePublished)),
                          Text(episode.duration! == 0
                              ? ""
                              : formatIntDuration(episode.duration!)),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 170.0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        episode.description,
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            isPlayerReady
                ? Positioned(
                    bottom: MediaQuery.of(context).padding.bottom,
                    left: 0,
                    right: 0,
                    child: PlayerControls(
                      episode: episode,
                    ),
                  )
                : Positioned(
                    bottom: MediaQuery.of(context).padding.bottom,
                    left: 0,
                    right: 0,
                    child: PlayButton(
                      episode: episode,
                      title: title,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
