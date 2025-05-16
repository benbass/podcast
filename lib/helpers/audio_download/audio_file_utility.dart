import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/episode_entity.dart';
import '../../domain/queued_audio_download/queued_audio_download.dart';
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

  static Map<String, bool> getDownloadStatus(EpisodeEntity episode){
    Map<String, bool> status = {
      "isDownloading": false,
      "isPending": false,
    };
    AudioDownloadQueueManager manager = AudioDownloadQueueManager();
    final downloadQueue = manager.downloadItems;
    if (downloadQueue.isNotEmpty) {
      final existingItemIndex =
      downloadQueue.indexWhere((item) => item.episode.id == episode.id);
      if (existingItemIndex != -1) {
        final existingItem = downloadQueue[existingItemIndex];
        status["isDownloading"] = existingItem.status == DownloadStatus.downloading;
        status["isPending"] = existingItem.status == DownloadStatus.pending;
      }
    }
    return status;
  }
}
