import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:podcast/helpers/core/perform_action_on_episode.dart';
import 'package:podcast/helpers/notifications/create_notification.dart';
import 'package:podcast/main.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/episode_entity.dart';
import '../notifications/notifications_controller.dart';

class DownloadException implements Exception {
  final String message;
  DownloadException(this.message);
}

class AudioDownloadService {
  BuildContext context = MyApp.navigatorKey.currentContext!;
  final EpisodeEntity episode;
  Dio dio = Dio();
  final CancelToken cancelToken = CancelToken();
  double progress = 0;
  final int notificationId;
  bool isDownloading = false;

  AudioDownloadService(this.episode) : notificationId = Random().nextInt(100000) + 11 {
    NotificationController().registerDownload(notificationId, this);
  }

  Future<void> _downloadFile(String url, String savePath, episodeTitle) async {
    isDownloading = true;
    progress = 0;
    try {
      await dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          progress = received / total * 100;
          if (total <= 0) return;
          createNotificationDownload(
              progress, savePath, episodeTitle, notificationId);
        },
      ).whenComplete(() {
        isDownloading = false;
        cancelNotificationDownload(notificationId);
        NotificationController().unregisterDownload(notificationId);
      });
    } on DioException catch (e) {
      isDownloading = false;
      throw DownloadException("Failed to download file: $e");
    } catch (e) {
      isDownloading = false;
      throw DownloadException("An error occurred: $e");
    }
  }

  String _removeQueryParameters(String url) {
    // Find the index of the first '?' character
    int questionMarkIndex = url.indexOf('?');

    // If '?' is found, remove everything from that index onwards
    if (questionMarkIndex != -1) {
      return url.substring(0, questionMarkIndex);
    } else {
      // If no '?' is found, return the original URL
      return url;
    }
  }

  /// Download episode to device and return filePath
  Future<String> _filePathOnDevice(EpisodeEntity episode) async {
    final String audioUrl = episode.enclosureUrl;
    final int fileSize = episode.enclosureLength;
    final String episodeTitle = episode.title;

    // Download directory for episode will be sub directory "episodes" in app directory
    Directory appDir = await getApplicationDocumentsDirectory();

    final episodesDir = Directory(path.join(appDir.path, 'episodes'));

    // Create the subdirectory if it doesn't exist
    if (!episodesDir.existsSync()) {
      await episodesDir.create(recursive: true);
    }

    // Use a UUID as the file name to avoid conflicts
    final fileName = const Uuid().v4();

    // Remove query parameters from URL before getting the extension
    final cleanedAudioUrl = _removeQueryParameters(audioUrl);

    // Get file extension from the url
    final fileExtension = path.extension(cleanedAudioUrl);
    // Create the full file path by joining the directory and the file name
    final filePath = path.join(episodesDir.path, "$fileName$fileExtension");

    // Check if file exists:
    final file = File(filePath);
    if (file.existsSync() && file.lengthSync() == fileSize) {
      // Already downloaded
      return filePath;
    } else {
      try {
        // File not downloaded, download it!
        await _downloadFile(audioUrl, filePath, episodeTitle);
      } catch (e) {
        rethrow; // Rethrow the exception for the caller to handle
      }
      return filePath; // Now downloaded!
    }
  }

  Future<void> _deletePartialDownload(String savePath) async {
    final file = File(savePath);
    if (await file.exists()) {
      await file.delete();
      debugPrint('Partial download $notificationId deleted');
    }
  }

  void cancelDownload(String savePath) {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel("Cancelled by user");
      debugPrint("Download $notificationId cancelled by user");
      _deletePartialDownload(savePath);
      dispose();
    }
  }

  void dispose(){
    dio.close();
    if (isDownloading) {
      NotificationController().unregisterDownload(notificationId);
    }
}

  void showDownloadDialog() {
    Navigator.pop(context); // close previous dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Text(episode.filePath == null
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
                onPressed: () async {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                  if (episode.filePath == null) {
                    try {
                      String savePath = await _filePathOnDevice(episode);
                      if (File(savePath).existsSync()) {
                        performActionOnEpisode(episode, "download", savePath);
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
                        performActionOnEpisode(episode, "delete", null);
                      } catch (e) {
                        debugPrint("Error deleting file: $e");
                      }
                    }
                  }
                },
                child: Text(episode.filePath == null ? "Download" : "Delete"),
              ),
            ]);
      },
    );
  }
}
