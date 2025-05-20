import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:podcast/helpers/core/episode_action_helper.dart';
import '../../../application/episode_selection_cubit/episode_selection_cubit.dart';
import '../../../core/globals.dart';
import '../../../domain/entities/episode_entity.dart';
import '../../../helpers/audio_download/audio_file_utility.dart';
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
              icon: Icons.check,
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
              icon: Icons.radio_button_unchecked,
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
              icon: Icons.star,
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
              icon: Icons.star_border,
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
      BuildContext context, EpisodeEntity episode) {
    // Reset for debugging purposes
    /* episode.filePath = null;
  episodeBox.put(episode);*/

    Map<String, bool> downloadStatus =
        AudioFileUtility.getDownloadStatus(episode);

    final List<Map<String, dynamic>> menuItems = [
      if (episode.isSubscribed)
        {
          "title": episode.read ? "Unmark as read" : "Mark as read",
          "onPressed": () {
            final bool isRead = episode.read;
            EpisodeActionHelper.performActionOnEpisode(episode, "read", isRead);
            Navigator.pop(context);
            ActionFeedback.show(context,
                icon:
                    episode.read ? Icons.check : Icons.radio_button_unchecked);
          }
        },
      {"title": "Share", "onPressed": () {}},
      {
        "title": episode.favorite ? "Unmark as favorite" : "Mark as favorite",
        "onPressed": () {
          final bool isFavorite = episode.favorite;
          EpisodeActionHelper.performActionOnEpisode(
              episode, "favorite", isFavorite);
          Navigator.pop(context);
          ActionFeedback.show(context,
              icon: episode.favorite ? Icons.star : Icons.star_border);
        }
      },
      {
        "title": downloadStatus["isDownloading"] == true
            ? "Downloading..."
            : downloadStatus["isPending"] == true
                ? "Pending..."
                : episode.filePath == null
                    ? "Download"
                    : "Delete",
        "onPressed": () {
          (downloadStatus["isDownloading"] == true ||
                  downloadStatus["isPending"] == true)
              ? null
              : AudioFileDialog.showAudioFileDialog(context, episode);
        },
      },
    ];

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
