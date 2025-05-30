import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/domain/usecases/episode_usecases.dart';
import 'package:podcast/presentation/custom_widgets/elevated_button_subscribe.dart';
import 'package:podcast/presentation/custom_widgets/page_transition.dart';
import 'package:podcast/presentation/custom_widgets/play_button.dart';
import 'package:podcast/presentation/episodes_list_page/episodes_list_page.dart';

import '../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../helpers/core/utilities/image_provider.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';
import '../audioplayer_overlays/audioplayer_overlays.dart';
import '../episodes_list_page/widgets/animated_download_icon.dart';
import 'episode_playback_progress_indicator.dart';

/// This widget displays details about a selected podcast or episode,
/// depending on which entity (podcast or episode) is provided.
class FlexibleSpace extends StatelessWidget {
  final PodcastEntity podcast;
  final EpisodeEntity? episode; // If null, widget displays podcast details.
  final String title;
  final String? flag;

  const FlexibleSpace({
    super.key,
    required this.podcast,
    this.episode,
    required this.title,
    this.flag,
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
              const Positioned(
                top: 70,
                left: 12,
                child: AnimatedDownloadIcon(size: 42),
              ),
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
                  ),
                ),
              if (episode != null)
                BlocBuilder<EpisodePlaybackCubit, EpisodePlaybackState>(
                  buildWhen: (previous, current) {
                    return previous.episode?.eId != current.episode?.eId;
                  },
                  builder: (context, currentlyPlayingEpisodeState) {
                    return Positioned(
                      bottom: 20,
                      left: 12,
                      child: StreamBuilder<EpisodeEntity?>(
                        stream: getIt<EpisodeUseCases>().getEpisodeStream(episodeId: episode!.id),
                        initialData: episode,
                        builder: (context, snapshot) {
                            final episodeInProgress = snapshot.data ?? episode!;
                            return EpisodePlaybackProgressIndicator(
                            themeData: themeData,
                            episode: episodeInProgress,
                            currentlyPlayingEpisode:
                                currentlyPlayingEpisodeState.episode,
                            dimension: 70,
                            paddingHoriz: 0,
                            paddingVert: 0,
                            strokeWidth: 6,
                          );
                        }
                      ),
                    );
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
      return episode!.image.isNotEmpty
          ? episode!.image
          : podcast.artworkFilePath != null
              ? podcast.artworkFilePath!
              : podcast.artwork;
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

  /// Builds the title content with back button and title text.
  Widget _buildTitleContent(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(
            flex: 3,
          ),
          IconButton(
            onPressed: () {
              if (episode != null) {
                final audioHandler = getIt<MyAudioHandler>();
                if (audioHandler.player.processingState ==
                        ProcessingState.ready &&
                    overlayEntry == null) {
                  showOverlayPlayerMin(context);
                }
              }
              Navigator.of(context).pushAndRemoveUntil(
                ScaleRoute(
                  page: const EpisodesListPage(),
                ),
                ModalRoute.withName('/'),
              );
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
