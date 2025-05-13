import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/episode_entity.dart';
import 'audio_download_queue_manager.dart';
import '../core/episode_action_helper.dart';

class AudioFileUtility {
  static void handleDownloadOnPressed(EpisodeEntity episode) async {
    if (episode.filePath == null) {
      // This starts the download!
      AudioDownloadQueueManager().addEpisodeToQueue(episode);
    } else {
      File file = File(episode.filePath!);
      if (file.existsSync()) {
        try {
          file.delete();
          EpisodeActionHelper.performActionOnEpisode(episode, "delete", null);
        } catch (e) {
          debugPrint("Error deleting file: $e");
        }
      }
    }
  }
}
