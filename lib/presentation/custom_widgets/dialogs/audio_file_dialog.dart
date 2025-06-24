import 'package:flutter/material.dart';
import 'package:podcast/presentation/custom_widgets/effects/backdropfilter.dart';

import '../../../domain/entities/episode_entity.dart';
import '../../../helpers/audio_download/audio_file_utility.dart';

class AudioFileDialog {
  static void showAudioFileDialog(
      BuildContext context, EpisodeEntity episode, String? filePath) {
    Navigator.pop(context); // close previous dialog
    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          children: [
            const BackdropFilterWidget(sigma: 4.0),
            AlertDialog(
                title: Text(filePath == null
                    ? "Download episode audio file to device"
                    : "Delete episode audio file"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      AudioFileUtility.handleDownloadOnPressed(episode);
                    },
                    child: Text(filePath == null ? "Download" : "Delete"),
                  ),
                ]),
          ],
        );
      },
    );
  }
}
