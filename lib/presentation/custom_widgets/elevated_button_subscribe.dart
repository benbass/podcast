import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:podcast/core/globals.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
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

  Future<void> _unsubscribe(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          children: [
            const BackdropFilterWidget(sigma: 4.0),
            AlertDialog(
                title: const Text(
                  "Are you sure you want to unsubscribe?",
                ),
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
                      Navigator.pop(context);
                      await _deleteUnFlaggedEpisodes();
                      if (context.mounted) {
                        BlocProvider.of<PodcastBloc>(context)
                            .add(UnSubscribeFromPodcastEvent(id: podcast.id));

                       Navigator.push(
                          context,
                          SlideRouteWithCurve(
                            page: const HomePage(),
                          ),
                        );
                      }
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
