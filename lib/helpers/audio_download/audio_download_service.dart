import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../domain/entities/episode_entity.dart';
import '../notifications/utilities_notifications.dart';
import '../notifications/notifications_controller.dart';

class DownloadException implements Exception {
  final String message;
  DownloadException(this.message);
}

class AudioDownloadService {
  final EpisodeEntity episode;
  Dio dio = Dio();
  final CancelToken cancelToken = CancelToken();
  double progress = 0;
  final int notificationId;
  bool isDownloading = false;

  AudioDownloadService(this.episode)
      : notificationId = Random().nextInt(100000) + 1 {
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
          UtilitiesNotifications.createNotificationDownload(
              progress, savePath, episodeTitle, notificationId);
        },
      ).whenComplete(() {
        isDownloading = false;
        UtilitiesNotifications.cancelNotificationDownload(notificationId);
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
  Future<String> filePathOnDevice(EpisodeEntity episode) async {
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

  void dispose() {
    dio.close();
    if (isDownloading) {
      NotificationController().unregisterDownload(notificationId);
    }
  }
}
