import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/presentation/episode_details_page/widgets/player_controls.dart';

import '../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../domain/entities/podcast_entity.dart';
import '../../helpers/core/format_duration.dart';
import '../../helpers/core/format_pubdate_string.dart';
import '../../helpers/listeners/player_listener.dart';
import '../../injection.dart';
import '../audioplayer_overlays/audioplayer_overlays.dart';
import '../custom_widgets/flexible_space.dart';
import 'widgets/podcast_website_link.dart';

class EpisodeDetailsPage extends StatelessWidget {
  final EpisodeEntity episode;
  final PodcastEntity podcast;

  const EpisodeDetailsPage({
    super.key,
    required this.episode,
    required this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    // We wrap this widget in PopScope so we can apply a method on the OS back-button
    // where we handle the overlay!
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          if (getIt<PlayerStatesListener>().player.processingState ==
                  ProcessingState.ready &&
              overlayEntry == null) {
            showOverlayPlayerMin(context, episode, podcast, podcast.title);
          }
        }
      },
      child: BlocBuilder<EpisodePlaybackCubit, EpisodeEntity?>(
        builder: (context, state) {
          state != null && state.eId == episode.eId ? removeOverlay() : null;
          return Scaffold(
            body: Stack(
              children: [
                SafeArea(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      FlexibleSpace(
                        podcast: podcast,
                        episode: episode,
                        title: episode.title,
                      ),
                      SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formatTimestamp(episode.datePublished)),
                              Icon(
                                episode.read && podcast.subscribed
                                    ? Icons.check_rounded
                                    : null,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              Icon(
                                episode.favorite
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: episode.favorite
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.white12,
                              ),
                              Icon(
                                Icons.save_alt_rounded,
                                color: episode.filePath != null
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.white12,
                              ),
                              Text(
                                episode.duration! == 0
                                    ? ""
                                    : intToDurationFormatted(
                                        episode.duration!,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 170.0),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                episode.description,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              if (episode.episodeNr != 0) ...[
                                Text(
                                    "${episode.episodeNr}/${podcast.episodeCount}"),
                                const SizedBox(height: 16.0),
                              ],
                              if (podcast.link != null &&
                                  podcast.link!.isNotEmpty &&
                                  podcast.link!.contains('://'))
                                PodcastWebsiteLink(link: podcast.link!),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: state != null && state.eId == episode.eId,
                  child: Positioned(
                    bottom: MediaQuery.of(context).padding.bottom,
                    left: 0,
                    right: 0,
                    child: const PlayerControls(),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
