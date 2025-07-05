import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/application/playback/playback_cubit/playback_cubit.dart';
import 'package:podcast/application/user_playlist/user_playlist_cubit/user_playlist_cubit.dart';

import 'package:podcast/core/globals.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/helpers/player/audiohandler.dart';
import 'package:podcast/presentation/custom_widgets/effects/backdropfilter.dart';
import 'package:podcast/presentation/custom_widgets/page_transition.dart';
import '../../application/podcast/podcast_bloc/podcast_bloc.dart';
import '../../domain/usecases/episode_usecases.dart';
import '../../helpers/core/connectivity_manager.dart';
import '../../injection.dart';
import '../../objectbox.g.dart';
import '../homepage/homepage.dart';
import 'dialogs/failure_dialog.dart';

class ElevatedButtonSubscribe extends StatelessWidget {
  final PodcastEntity podcast;

  const ElevatedButtonSubscribe({
    super.key,
    required this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        !podcast.subscribed
            ? await _subscribeToPodcast(context)
            : await _unsubscribe(context);
      },
      child: BlocBuilder<PodcastBloc, PodcastState>(
        builder: (context, state) {
          return state.status != PodcastStatus.loading
              ? SizedBox(
                  width: 80,
                  child: Text(
                    state.currentPodcast.subscribed
                        ? "Unsubscribe"
                        : "Subscribe",
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox(
                  width: 80,
                  child: CircularProgressIndicator(
                    constraints: BoxConstraints(
                      maxWidth: 28,
                      minHeight: 28,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 3,
                      horizontal: 24,
                    ),
                  ),
                );
        },
      ),
    );
  }

  /// SUBSCRIBE
  Future<void> _handleEpisodes(BuildContext context) async {
    try {
      await getIt<EpisodeUseCases>().fetchRemoteEpisodesByFeedIdAndSaveToDb(
        feedId: podcast.feedId,
        markAsSubscribed: true,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error fetching episodes.}")),
        );
      }
      rethrow; // For try-catch bloc in _subscribeToPodcast (the caller)!
    }
  }

  Future<void> _subscribeToPodcast(BuildContext context) async {
    final String connectionType =
        await getIt<ConnectivityManager>().getConnectionTypeAsString();
    if (connectionType != 'none' && context.mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const Stack(
            children: [
              BackdropFilterWidget(sigma: 4.0),
              AlertDialog(
                title: Text("Subscribing..."),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Please wait."),
                  ],
                ),
              ),
            ],
          );
        },
      );
      try {
        await _handleEpisodes(context);
        if (context.mounted) {
          BlocProvider.of<PodcastBloc>(context)
              .add(SubscribeToPodcastEvent(podcast: podcast));
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        if (context.mounted) {
          showDialog(
              context: context,
              builder: (context) => const FailureDialog(
                  message: "Failed to subscribe. Please try again later."));
        }
      }
    } else {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) =>
                const FailureDialog(message: "No internet connection!"));
      }
    }
  }

  /// UNSUBSCRIBE
  /*
  // This method may be used in a future app version:
  Future<void> _deleteUnFlaggedEpisodes() async {
    // We do not just delete the episodes from the db: User may have
    // flagged some episodes so we  want to keep them.
    // 1. we set isSubscribed to false for all episodes anyway
    final episodesQueryBuilder =
        episodeBox.query(EpisodeEntity_.feedId.equals(podcast.feedId)).build();
    final results = episodesQueryBuilder.find();
    for (var ep in results) {
      ep.isSubscribed = false;
      episodeBox.put(ep);
    }

    // 2. We query all ids for episodes with no flag
    final idsQueryBuilder = episodeBox
        .query(EpisodeEntity_.feedId
            .equals(podcast.feedId)
            .and(EpisodeEntity_.favorite.equals(false))
            .and(EpisodeEntity_.filePath.isNull())
            .and(EpisodeEntity_.position.equals(0)))
        .build();
    final determinedIds = idsQueryBuilder.findIds();

    // 3. We delete the episodes in db
    episodeBox.removeMany(determinedIds);
  }
  */

  Future<void> _deleteEpisodes() async {
    final episodeIdsQueryBuilder =
        episodeBox.query(EpisodeEntity_.feedId.equals(podcast.feedId)).build();
    final result = episodeIdsQueryBuilder.findIds();
    episodeBox.removeMany(result);
  }

  Future<void> _deleteData(BuildContext context) async {
    Navigator.pop(context);

    bool operationSuccessful = true;

    try {
      // 1: Stop playback if it is playing an episode from this podcast
      if (context.read<PlaybackCubit>().state.episode?.feedId ==
          podcast.feedId) {
        try {
          await getIt<MyAudioHandler>().stop();
        } catch (e, s) {
          operationSuccessful = false;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Could not stop playback.")),
            );
          }
          debugPrint("Error stopping audio handler: $e\n$s");
          // operationSuccessful = false; // We will go ahead and delete the data anyway
        }
      }

      // 2: Clean the UserPlaylist if it contains episodes from this podcast
      try {
        if (context.mounted) {
          await BlocProvider.of<UserPlaylistCubit>(context)
              .removeEpisodeIdsByFeed(feedId: podcast.feedId);
        }
      } catch (e, s) {
        operationSuccessful = false;
        debugPrint("Error cleaning user playlist: $e\n$s");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "Could not fully clean up this podcast's episodes from your playlist.\nYou may have to do it manually and try again to unsubscribe.")),
          );
        }
      }

      // 3: Delete episodes from database
      try {
        await _deleteEpisodes();
      } catch (e, s) {
        operationSuccessful = false;
        debugPrint("Error deleting episodes from database: $e\n$s");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "Failed to delete all podcast episodes from storage.")),
          );
        }
      }
    } catch (e, s) {
      // For unexpected errors
      operationSuccessful = false;
      debugPrint("An unexpected error occurred during data deletion: $e\n$s");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "An unexpected error occurred. Some cleanup may not be complete.")),
        );
      }
    }

    // 4. Delete podcast from database
    if (context.mounted) {
      if (operationSuccessful) {
        BlocProvider.of<PodcastBloc>(context)
            .add(UnSubscribeFromPodcastEvent(id: podcast.id));

        Navigator.pushAndRemoveUntil(
          context,
          SlideRouteWithCurve(page: const HomePage()),
          (route) => false,
        );
      } else {
        showDialog(
            context: context,
            builder: (context) => const FailureDialog(
                message:
                    "Failed to unsubscribe. Some cleanup may not be complete.\nYou may close the app and try again"));
      }
    }
  }

  Future<void> _unsubscribe(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          children: [
            const BackdropFilterWidget(sigma: 4.0),
            AlertDialog(
                title: const Text(
                  "Are you sure you want to unsubscribe from this podcast?",
                ),
                content: const Text("This will delete all data and remove the relevant podcast episodes from your playlist."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      _deleteData(context);
                    },
                    child: const Text(
                      "Unsubscribe",
                    ),
                  ),
                ]),
          ],
        );
      },
    );
  }
}
