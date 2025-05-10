import 'package:flutter/material.dart';

import '../../domain/entities/episode_entity.dart';
import '../../helpers/core/perform_action_on_episode.dart';
import 'action_feedback/action_feedback.dart';

class EpisodeActionsRow extends StatelessWidget {
  final EpisodeEntity episode;
  final bool? showSpacer;
  const EpisodeActionsRow({super.key, required this.episode, this.showSpacer});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 30,
      children: [
        const Spacer(),
        Icon(
          episode.read ? Icons.check_rounded : null,
          size: 30.0,
          color: Theme.of(context).colorScheme.primary,
        ),
        //const Spacer(),
        IconButton(
          onPressed: () {
            final bool isFavorite = episode.favorite;
            performActionOnEpisode(episode, "favorite", isFavorite);
            ActionFeedback.show(context,
                icon: episode.favorite ? Icons.star : Icons.star_border);
          },
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          icon: Icon(
            episode.favorite ? Icons.star_rounded : Icons.star_border_rounded,
            size: 30.0,
            color: episode.favorite
                ? Theme.of(context).colorScheme.primary
                : Colors.white12,
          ),
        ),
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(episode.filePath != null
                      ? "Delete the downloaded file?"
                      : "Download the episode?"),
                  content: Text(episode.filePath != null
                      ? "This cannot be undone."
                      : "This will download the file to your device."),
                  actions: [
                    TextButton(
                      onPressed: () => {
                        Navigator.pop(context),
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Handle download/delete
                        String? filePath = episode.filePath;
                        if (filePath == null) {
                          // implement logic for download and set filePath as String for performActionOnEpisode
                          filePath = "file path on device";
                        } else {
                          // implement logic for delete and set filePath as null for performActionOnEpisode
                          filePath = null;
                        }
                        performActionOnEpisode(
                            episode, "download", filePath);
                        Navigator.pop(context);
                      },
                      child: Text(
                          episode.filePath != null ? "Delete" : "Download"),
                    ),
                  ],
                );
              },
            );
          },
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          icon: Icon(
            episode.filePath != null
                ? Icons.delete_rounded
                : Icons.save_alt_rounded,
            size: 30.0,
            color: episode.filePath != null
                ? Theme.of(context).colorScheme.primary
                : Colors.white12,
          ),
        ),
        if (showSpacer ?? true) const Spacer(),
      ],
    );
  }
}
