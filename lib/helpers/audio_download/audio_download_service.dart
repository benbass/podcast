import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../domain/entities/episode_entity.dart';

class DownloadException implements Exception {
  final String message;
  DownloadException(this.message);
}

class AudioDownloadService {
  final EpisodeEntity episode;
  Dio dio = Dio();
  final CancelToken cancelToken = CancelToken();

  // Callbacks for progress and completion
  final Function(double)? onProgressUpdate;
  final Function()? onDownloadComplete;

  AudioDownloadService(this.episode,
      {this.onProgressUpdate, this.onDownloadComplete});

  Future<void> _downloadFile(String url, String savePath) async {
    try {
      await dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          double currentProgress = received / total;
          // Notify the callback about the progress
          onProgressUpdate?.call(currentProgress);
        },
      );
      // Notify the Callback about the completion, only if the download was successful
      onDownloadComplete?.call();
    } on DioException catch (e) {
      dispose();
      throw DownloadException("Failed to download file: $e");
    } catch (e) {
      dispose();
      throw DownloadException("An error occurred: $e");
    }
  }

  String _removeQueryParameters(String url) {
    int questionMarkIndex = url.indexOf('?');
    if (questionMarkIndex != -1) {
      return url.substring(0, questionMarkIndex);
    } else {
      return url;
    }
  }

  /// Download episode to device and return filePath
  Future<String> filePathOnDevice() async {
    final String audioUrl = episode.enclosureUrl;
    final int fileSize = episode.enclosureLength;

    // Download directory for episode will be sub directory "episodes" in app directory
    Directory appDir = await getApplicationDocumentsDirectory();

    final episodesDir = Directory(path.join(appDir.path, 'episodes'));

    // Create the subdirectory if it doesn't exist
    if (!episodesDir.existsSync()) {
      await episodesDir.create(recursive: true);
    }

    // Use a UUID as the file name to avoid conflicts
    final fileName = const Uuid().v4();

    // Clean URL from query parameters before getting the extension
    final cleanedAudioUrl = _removeQueryParameters(audioUrl);

    // Get file extension from the url
    final fileExtension = path.extension(cleanedAudioUrl);
    // Create the full file path by joining the directory and the file name
    final filePath = path.join(episodesDir.path, "$fileName$fileExtension");

    // Check if file exists:
    final file = File(filePath);
    if (file.existsSync() && file.lengthSync() == fileSize) {
      // Already downloaded
      onDownloadComplete?.call(); // Notify the Callback about the completion
      return filePath;
    } else {
      try {
        debugPrint(
            'Starting Dio download. CancelToken hash passed: ${cancelToken.hashCode}');
        // File not downloaded, download it!
        await _downloadFile(audioUrl, filePath);
      } on DioException catch (e) {
        if (e.type == DioExceptionType.cancel) {
          try {
            // Dio should have deleted the partial file if download was cancelled, but just in case
            if (await file.exists()) {
              await file.delete();
            }
          } catch (deleteError) {
            debugPrint('Error deleting partial file: $deleteError');
          }
          throw DownloadException("Cancelled");
        } else {
          throw DownloadException("Failed: ${e.message}");
        }
      } catch (e) {
        rethrow;
      } finally {}
      return filePath; // Now downloaded!
    }
  }

  void cancelDownload() async {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel("Cancelled by user");
      onDownloadComplete?.call(); // Notify the Callback about the cancellation
    }
  }

  void dispose() {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel("Cancelled by dispose");
    }
    dio.close();
  }
}
