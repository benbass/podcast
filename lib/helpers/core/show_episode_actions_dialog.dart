import 'package:flutter/material.dart';
import 'package:podcast/helpers/core/perform_action_on_episode.dart';

import '../../domain/entities/episode_entity.dart';
import '../../presentation/custom_widgets/action_feedback/action_feedback.dart';

void showEpisodeActionsDialog(BuildContext context, EpisodeEntity episode) {
  final List<Map<String, dynamic>> menuItems = [
    if (episode.isSubscribed)
      {
        "title": episode.read ? "Unmark as read" : "Mark as read",
        "onPressed": () {
          final bool isRead = episode.read;
          performActionOnEpisode(episode, "read", isRead, context);
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
        performActionOnEpisode(episode, "favorite", isFavorite, context);
        Navigator.pop(context);
        ActionFeedback.show(context,
            icon: episode.favorite ? Icons.star : Icons.star_border);
      }
    },
    {
      "title": episode.filePath == null ? "Download" : "Delete",
      "onPressed": () {
        // TODO: Handle download/delete
        String? filePath = episode.filePath;
        if (filePath == null) {
          // implement logic for download and set filePath as String for performActionOnEpisode
          filePath = "file path on device";
        } else {
          // implement logic for delete and set filePath as null for performActionOnEpisode
          filePath = null;
        }
        performActionOnEpisode(episode, "download", filePath, context);
        Navigator.pop(context);
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