import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:podcast/helpers/database/episode_action_helper.dart';
import 'package:share_plus/share_plus.dart';
import '../../../application/episode_selection_cubit/episode_selection_cubit.dart';
import '../../../core/globals.dart';
import '../../../domain/entities/episode_entity.dart';
import '../../../domain/usecases/episode_usecases.dart';
import '../../../helpers/audio_download/audio_file_utility.dart';
import '../../../injection.dart';
import '../action_feedback/action_feedback.dart';
import 'audio_file_dialog.dart';

class EpisodeActionsDialog {
  static void showSelectedEpisodesActionDialog(
      BuildContext context, List<EpisodeEntity> episodes) {
    final List<Map<String, dynamic>> menuItems = [
      {
        "title": "Mark as read",
        "onPressed": () {
          for (var episode in episodes) {
            episode.read = true;
            episodeBox.put(episode);
            ActionFeedback.show(
              context,
              icon: Icons.check_rounded,
            );
          }
          BlocProvider.of<EpisodeSelectionCubit>(context).toggleSelectionMode();
          Navigator.pop(context);
        }
      },
      {
        "title": "Unmark as read",
        "onPressed": () {
          for (var episode in episodes) {
            episode.read = false;
            episodeBox.put(episode);
            ActionFeedback.show(
              context,
              icon: Icons.check_rounded,
            );
          }
          BlocProvider.of<EpisodeSelectionCubit>(context).toggleSelectionMode();
          Navigator.pop(context);
        }
      },
      {
        "title": "Mark as favorite",
        "onPressed": () {
          for (var episode in episodes) {
            episode.favorite = true;
            episodeBox.put(episode);
            ActionFeedback.show(
              context,
              icon: Icons.star_rounded,
            );
          }
          BlocProvider.of<EpisodeSelectionCubit>(context).toggleSelectionMode();
          Navigator.pop(context);
        }
      },
      {
        "title": "Unmark as favorite",
        "onPressed": () {
          for (var episode in episodes) {
            episode.favorite = false;
            episodeBox.put(episode);
            ActionFeedback.show(
              context,
              icon: Icons.star_rounded,
            );
          }
          BlocProvider.of<EpisodeSelectionCubit>(context).toggleSelectionMode();
          Navigator.pop(context);
        }
      },
    ];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choose an action for the selected episodes"),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var menuItem in menuItems)
                TextButton(
                  onPressed: () => menuItem["onPressed"](),
                  child: Text(menuItem["title"]),
                ),
            ],
          ),
        );
      },
    );
  }

  static void showEpisodeActionsDialog(
      BuildContext context, EpisodeEntity episode) async {
    // Reset for debugging purposes
    /* episode.filePath = null;
  episodeBox.put(episode);*/

    Map<String, bool> downloadStatus =
        AudioFileUtility.getDownloadStatus(episode);
    final String? filePath = await getIt<EpisodeUseCases>()
        .getEpisodeStream(episodeId: episode.id)
        .first.then((value) => value?.filePath);

    final List<Map<String, dynamic>> menuItems = [
      if (episode.isSubscribed)
        {
          "title": episode.read ? "Unmark as read" : "Mark as read",
          "onPressed": () {
            final bool isRead = episode.read;
            EpisodeActionHelper.performActionOnEpisode(episode, "read", isRead);
            Navigator.pop(context);
            ActionFeedback.show(context, icon: Icons.check_rounded);
          }
        },
      {
        "title": "Share",
        "onPressed": () async {
          await SharePlus.instance.share(ShareParams(
            subject: episode.podcastTitle,
            text:
                "${episode.podcastTitle}\n${episode.title}\n\nLink to episode:\n${episode.enclosureUrl}",
          ));
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      {
        "title": episode.favorite ? "Unmark as favorite" : "Mark as favorite",
        "onPressed": () {
          final bool isFavorite = episode.favorite;
          EpisodeActionHelper.performActionOnEpisode(
              episode, "favorite", isFavorite);
          Navigator.pop(context);
          ActionFeedback.show(context, icon: Icons.star_rounded);
        }
      },
      {
        "title": downloadStatus["isDownloading"] == true
            ? "Downloading..."
            : downloadStatus["isPending"] == true
                ? "Pending..."
                : filePath == null
                    ? "Download"
                    : "Delete",
        "onPressed": () async {
          (downloadStatus["isDownloading"] == true ||
                  downloadStatus["isPending"] == true)
              ? null
              : {
                  if (context.mounted)
                    AudioFileDialog.showAudioFileDialog(
                        context, episode, filePath)
                };
        },
      },
    ];

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var menuItem in menuItems)
                  TextButton(
                    onPressed: () => menuItem["onPressed"](),
                    child: Text(menuItem["title"]),
                  ),
              ],
            ),
          );
        },
      );
    }
  }
}
