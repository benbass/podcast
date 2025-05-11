import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/episode_entity.dart';
import '../core/episode_action_helper.dart';
import 'audio_download_service.dart';

class AudioFileUtility {
  static void handleDownloadOnPressed(EpisodeEntity episode) async {
    if (episode.filePath == null) {
      try {
        AudioDownloadService audioDownloadService =
            AudioDownloadService(episode);
        String savePath = await audioDownloadService.filePathOnDevice(episode);
        if (File(savePath).existsSync()) {
          EpisodeActionHelper.performActionOnEpisode(episode, "download", savePath);
        }
      } on DownloadException catch (e) {
        // Handle download error
        debugPrint(e.message);
      } catch (e) {
        // Handle any other potential error
        debugPrint("An error occured: $e");
      }
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
