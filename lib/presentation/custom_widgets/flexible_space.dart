import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/custom_widgets/elevated_button_subscribe.dart';
import 'package:podcast/presentation/custom_widgets/play_button.dart';

import '../../helpers/core/image_provider.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';
import '../audioplayer_overlays/audioplayer_overlays.dart';

/// This widget displays details about a selected podcast or episode,
/// depending on which entity (podcast or episode) is provided.
class FlexibleSpace extends StatelessWidget {
  final PodcastEntity podcast; // If null, widget displays episode details.
  final EpisodeEntity? episode; // If null, widget displays podcast details.
  final String title;

  const FlexibleSpace({
    super.key,
    required this.podcast,
    this.episode,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    final String imageUrl = _getImageUrl();

    return SliverAppBar(
      collapsedHeight: 90,
      expandedHeight: MediaQuery.of(context).size.height / 3,
      pinned: true,
      leading: null,
      automaticallyImplyLeading:
          false, // we remove the default back-button, together with leading: null
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.only(
            bottom: 70,
          ),
          child: Stack(
            children: [
              _buildBackgroundImage(imageUrl),
              //_buildGradientOverlay(),
              if (episode == null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: ElevatedButtonSubscribe(
                    navigate: false,
                    podcast: podcast,
                  ),
                ),
              if (episode != null)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: PlayButton(
                    episode: episode!,
                    podcast: podcast,
                    podcastTitle: title,
                  ),
                ),
              if (episode != null)
                StreamBuilder<Duration>(
                  stream: getIt<MyAudioHandler>().player.positionStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final currentDuration = snapshot.data!;
                      final totalDuration =
                      Duration(seconds: episode!.duration!);
                      final progress = currentDuration.inMilliseconds /
                          totalDuration.inMilliseconds;
                      return Positioned(
                        bottom: 0,
                        left: 0,
                        child: SizedBox(
                          height: 7,
                          width: MediaQuery.of(context).size.width,
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            color: themeData.colorScheme.secondary
                                .withValues(alpha: 0.4),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      );
                    } else {
                      return Positioned(
                        bottom: 0,
                        left: 0,
                        child: SizedBox(
                          height: 7,
                          width: MediaQuery.of(context).size.width,
                          child: LinearProgressIndicator(
                            value: (episode!.position.toDouble() /
                                episode!.duration!.toDouble())
                                .clamp(0.0, 1.0),
                            color: themeData.colorScheme.secondary
                                .withValues(alpha: 0.4),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
        titlePadding: const EdgeInsets.all(4.0),
        expandedTitleScale: 1.5,
        title: _buildTitleContent(context),
      ),
    );
  }

  /// Determines the image URL based on whether an episode or podcast is provided.
  String _getImageUrl() {
    if (episode != null) {
      return episode!.image.isNotEmpty ? episode!.image : podcast.artworkFilePath != null ? podcast.artworkFilePath! : podcast.artwork;
    } else if (episode == null) {
      return podcast.artworkFilePath ?? podcast.artwork;
    } else {
      return '';
    }
  }

  /// Builds the background image with blur effect.
  Widget _buildBackgroundImage(String imageUrl) {
    return FutureBuilder<ImageProvider>(
      future: MyImageProvider(url: imageUrl).imageProvider,
      builder: (BuildContext context, AsyncSnapshot<ImageProvider> snapshot) {
        final ImageProvider imageProvider = snapshot.hasData
            ? snapshot.data!
            : const AssetImage('assets/placeholder.png');

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: episode == null && podcast.subscribed
                  ? podcast.artworkFilePath != null
                      ? FileImage(File(podcast.artworkFilePath!))
                      : const AssetImage('assets/placeholder.png')
                  : imageProvider,
              fit: BoxFit.fitWidth,
            ),
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: episode == null && podcast.subscribed
                          ? podcast.artworkFilePath != null
                          ? FileImage(File(podcast.artworkFilePath!))
                          : const AssetImage('assets/placeholder.png')
                          : imageProvider,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds a semi-transparent black overlay.
  Widget _buildGradientOverlay() {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: const BoxDecoration(
        color: Colors.black26,
      ),
    );
  }

  /// Builds the title content with back button and title text.
  Widget _buildTitleContent(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 3,),
          IconButton(
            onPressed: () {
              if (episode != null) {
                final audioHandler = getIt<MyAudioHandler>();
                if (audioHandler.player.processingState ==
                        ProcessingState.ready &&
                    overlayEntry == null) {
                  showOverlayPlayerMin(context, episode!, podcast, title);
                }
              }
              Navigator.of(context).pop();
            },
            icon: const BackButtonIcon(),
          ),
          const Spacer(flex: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 14,
                  ),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
