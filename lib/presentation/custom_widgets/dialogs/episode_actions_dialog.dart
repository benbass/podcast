import 'package:flutter/material.dart';

import 'package:podcast/helpers/core/episode_action_helper.dart';
import '../../../domain/entities/episode_entity.dart';
import '../action_feedback/action_feedback.dart';
import 'audio_file_dialog.dart';

class EpisodeActionsDialog{
  static void showEpisodeActionsDialog(BuildContext context, EpisodeEntity episode) {
    // Reset for debugging purposes
    /* episode.filePath = null;
  episodeBox.put(episode);*/

    final List<Map<String, dynamic>> menuItems = [
      if (episode.isSubscribed)
        {
          "title": episode.read ? "Unmark as read" : "Mark as read",
          "onPressed": () {
            final bool isRead = episode.read;
            EpisodeActionHelper.performActionOnEpisode(episode, "read", isRead);
            Navigator.pop(context);
            ActionFeedback.show(context,
                icon: episode.read ? Icons.check : Icons.radio_button_unchecked);
          }
        },
      {"title": "Share", "onPressed": () {}},
      {
        "title": episode.favorite ? "Unmark as favorite" : "Mark as favorite",
        "onPressed": () {
          final bool isFavorite = episode.favorite;
          EpisodeActionHelper.performActionOnEpisode(episode, "favorite", isFavorite);
          Navigator.pop(context);
          ActionFeedback.show(context,
              icon: episode.favorite ? Icons.star : Icons.star_border);
        }
      },
      {
        "title": episode.filePath == null ? "Download" : "Delete",
        "onPressed": () {
          AudioFileDialog.showAudioFileDialog(context, episode);
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


