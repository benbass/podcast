import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:podcast/domain/queued_audio_download/queued_audio_download.dart';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/core/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_download_service.dart';
import '../notifications/notifications_controller.dart';

class AudioDownloadQueueManager with ChangeNotifier {
  static final AudioDownloadQueueManager _instance =
      AudioDownloadQueueManager._internal();

  factory AudioDownloadQueueManager() => _instance;

  AudioDownloadQueueManager._internal();

  final List<QueuedAudioDownload> _downloadItems =
      []; // List of QueuedDownload objects
  final Queue<QueuedAudioDownload> _pendingQueue =
      Queue<QueuedAudioDownload>(); // Queue for pending downloads

  // Currently downloading item.
  // An update of this item requires an update of the corresponding item in _downloadItems!!!
  QueuedAudioDownload? _currentDownloadItem;

  bool _isProcessing = false;

  // Eindeutige Notification ID für die Queue-Benachrichtigung
  static const int _queueNotificationId = 99999;
  static const String _notificationPayloadActionKey = 'action';
  static const String _showQueueAction = 'show_queue';

  // Method to add an episode to the download queue
  void addEpisodeToQueue(EpisodeEntity episode) {
    final existingItemIndex = _downloadItems.indexWhere((item) => item.episode.id == episode.id);

    if (existingItemIndex != -1) {
      // Item already exists in the list
      final existingItem = _downloadItems[existingItemIndex];
      if (existingItem.status == DownloadStatus.cancelled || existingItem.status == DownloadStatus.failed) {
        // Case: Item already exists and was cancelled or failed -> Re-add it
        debugPrint("Re-queueing previously cancelled episode: ${episode.title}");
        // Remove the old, cancelled item from the list
        _downloadItems.removeAt(existingItemIndex);
        // Add the episode as a new item
        _addNewDownloadToQueues(episode);
      } else {
        // Case: Item already exists and is not cancelled or did not fail (pending, downloading, completed)
        debugPrint(
            "Episode already in queue with status '${existingItem.status}': ${episode.title}");
      }
    } else {
      // Case: Item does not exist in the list. Just add it to the queue
      debugPrint("Adding new episode to download queue: ${episode.title}");
      _addNewDownloadToQueues(episode);
    }
  }

  // Helper method to add an episode to the download queue
  void _addNewDownloadToQueues(EpisodeEntity episode) {
    final newQueuedDownload = QueuedAudioDownload(episode: episode);
    _downloadItems.add(newQueuedDownload);
    _pendingQueue.add(newQueuedDownload);
    notifyListeners(); // Inform the UI about the change
    _processNextInQueue(); // Try to start the next download
    _updateQueueNotification(); // Update the notification
  }

  // Method to start the next download in the queue
  void _processNextInQueue() async {
    if (_isProcessing || _pendingQueue.isEmpty) {
      if (_downloadItems.every((item) =>
          item.status != DownloadStatus.pending &&
          item.status != DownloadStatus.downloading)) {
        // All downloads are completed, failed or cancelled
        _isProcessing = false; // Make sure the state is correct
        _updateQueueNotification(); // Close the notification
      }
      return; // Already processing or no more items in the queue
    }

    _isProcessing = true;
    _currentDownloadItem = _pendingQueue.removeFirst();

    // Update the status of the current download item
    _updateDownloadItemStatus(
        _currentDownloadItem!.id, DownloadStatus.downloading);

    final audioService = AudioDownloadService(
      _currentDownloadItem!.episode,
      onProgressUpdate: (progress) {
        // Notify the UI about the progress
        _updateDownloadItemProgress(_currentDownloadItem!.id, progress);
        // Update the notification progress
        _updateQueueNotification(progress: progress);
      },
      onDownloadComplete: () {
        // _updateQueueNotification(); // Wird z.Z. gebraucht um die page aufrufen zu können
        /// TODO: implement whatever you want to do after the download is complete
      },
    );

    // Assign the audioService to both _currentDownloadItem and the object in _downloadItems
    _currentDownloadItem!.downloadService = audioService;

    // Find the object in _downloadItems and assign the audioService to it
    final index = _downloadItems
        .indexWhere((item) => item.id == _currentDownloadItem!.id);
    if (index != -1) {
      _downloadItems[index] = _downloadItems[index].copyWith(
        downloadService: audioService,
      );
    } else {
      // This should never happen
      debugPrint(
          'ERROR: Item with ID ${_currentDownloadItem!.id} not found in _downloadItems after removing from pendingQueue!');
    }
    final prefs = await SharedPreferences.getInstance();
    _currentDownloadItem!.downloadService!.filePathOnDevice().then((filePath) async {
      // Download successful
      _updateEpisodeFilePathInDb(_currentDownloadItem!.episode, filePath);
      // Remove the file path of the current download item from the shared preferences
      await prefs.remove(kCurrentDownloadFilePath);
      _updateDownloadItemStatus(
          _currentDownloadItem!.id, DownloadStatus.completed,
          filePath: filePath);
      _currentDownloadItem?.downloadService?.dispose();
      _currentDownloadItem = null;
      _isProcessing = false;
      _processNextInQueue();
      _updateQueueNotification();
    }).catchError((error) async {
      // Download failed or cancelled
      debugPrint(
          "Download failed or cancelled for: ${_currentDownloadItem!.episode.title} - $error");

      DownloadStatus status = DownloadStatus.failed;
      if (error is DownloadException && error.message.contains("Cancelled")) {
        status = DownloadStatus.cancelled;
      }

      await prefs.remove(kCurrentDownloadFilePath);
      _updateDownloadItemStatus(_currentDownloadItem!.id, status);
      _currentDownloadItem?.downloadService?.dispose();
      _currentDownloadItem = null;
      _isProcessing = false;
      _processNextInQueue();
      _updateQueueNotification();
    });

    _updateQueueNotification(); // initial notification
  }

  // Method to update the file path in the database
  void _updateEpisodeFilePathInDb(EpisodeEntity episode, String filePath) {
    try {
      final episodeFromDb = episodeBox.get(episode.id);
      if (episodeFromDb != null) {
        episodeFromDb.filePath = filePath;
        episodeBox.put(episodeFromDb);
      }
    } catch (e) {
      debugPrint(
          "Error updating episode filePath in DB: ${episode.title} - $e");
    }
  }

  // Method to update the status of a download item in the list and notify the UI
  void _updateDownloadItemStatus(String id, DownloadStatus status,
      {String? filePath}) {
    final index = _downloadItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      _downloadItems[index] =
          _downloadItems[index].copyWith(status: status, filePath: filePath);
      notifyListeners();
    }
  }

  void _updateDownloadItemProgress(String id, double progress) {
    final index = _downloadItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      _downloadItems[index] =
          _downloadItems[index].copyWith(progress: progress);
      notifyListeners();
    }
  }

  // Method to update the queue notification
  void _updateQueueNotification({double progress = 0}) {
    final pendingOrDownloading = _downloadItems
        .where((item) =>
            item.status == DownloadStatus.pending ||
            item.status == DownloadStatus.downloading)
        .toList();
    final total = _downloadItems.length;
    final completed = _downloadItems
        .where((item) => item.status == DownloadStatus.completed)
        .length;
    final cancelled = _downloadItems.where((item) => item.status == DownloadStatus.cancelled).length;

    if (pendingOrDownloading.isEmpty && total > 0 && completed == total) {
      // All Downloads completed
      AwesomeNotifications().cancel(_queueNotificationId);
      return;
    } else if (total == 0) {
      // No downloads in the list (e.g. after deleting all items)
      AwesomeNotifications().cancel(_queueNotificationId);
      return;
    }

    final String title = _isProcessing
        ? "Downloading: ${_currentDownloadItem?.episode.title ?? 'Unknown'}"
        : "Download Queue";
    final String body = _isProcessing
        ? "(${completed+1}/${total-cancelled}) - ${(progress * 100).toStringAsFixed(0)}%"
        : "$completed/$total items in queue";
    final double currentProgress = _isProcessing ? (progress * 100) : 0;

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _queueNotificationId,
        channelKey: NotificationController.notificationChannelKey,
        title: title,
        body: body,
        progress: currentProgress,
        locked: pendingOrDownloading
            .isNotEmpty, // Visible only when downloads are pending or running
        notificationLayout: NotificationLayout.ProgressBar,
        payload: {
          _notificationPayloadActionKey:
              _showQueueAction, // Payload for action "Show Queue"
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: NotificationController.showQueueActionKey,
          label: 'Show Queue',
          actionType: ActionType.Default,
          // payload: {'action': 'show_queue'} // Payload is being inherited from content
        )
      ],
    );
  }

  // method to cancel a specific download in the queue
  void cancelDownload(String id) {
    final itemToCancel = _downloadItems.firstWhere((item) => item.id == id);
    if (itemToCancel.status == DownloadStatus.pending) {
      // When the download is not yet started, just remove it from the pending queue
      _pendingQueue.remove(itemToCancel);
      _updateDownloadItemStatus(id, DownloadStatus.cancelled);
      _updateQueueNotification();
    } else if (itemToCancel.status == DownloadStatus.downloading) {
      // When the download is already started, cancel  the service
      itemToCancel.downloadService?.cancelDownload();
      // The status will be set to cancelled in _processNextInQueue() in the catchError block
      _updateQueueNotification();
    } else {
      debugPrint(
          "Attempted to cancel download with status: ${itemToCancel.status}");
    }
  }

  // Method to remove an item from the list (e.g. after completion or cancellation)
  void removeItem(String id) {
    _downloadItems.removeWhere((item) => item.id == id);
    // Make sure it's not in the pending queue either
    _pendingQueue.removeWhere((item) => item.id == id);
    notifyListeners();
    _updateQueueNotification();
  }

  // Returns an unmodifiable list of download items
  List<QueuedAudioDownload> get downloadItems =>
      List.unmodifiable(_downloadItems);

  // Method to open the download queue page from the notification. The callback is set in main.dart
  Function()? onShowQueuePage;

  // Method to cancel all downloads in the queue. Used only by dispose()
  void cancelAllDownloads() {
    for (final item in _downloadItems) {
      item.downloadService?.cancelDownload();
    }

    _pendingQueue.clear();
    _isProcessing = false;
    _updateQueueNotification();
  }

   static Future<void> cleanupLastPartialDownload() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastDownloadFilePath = prefs.getString(kCurrentDownloadFilePath);

    if (lastDownloadFilePath != null) {
      debugPrint("Found potential partial file to clean up: $lastDownloadFilePath");
      try {
        final file = File(lastDownloadFilePath);
        if (await file.exists()) {
          await file.delete();
          debugPrint("Successfully deleted partial file: $lastDownloadFilePath");
        } else {
          debugPrint("Partial file not found (already deleted or wrong path): $lastDownloadFilePath");
        }
      } catch (e) {
        debugPrint("Error deleting partial file $lastDownloadFilePath: $e");
      } finally {
        // In jedem Fall den Eintrag entfernen, um nicht wiederholt zu versuchen
        await prefs.remove(kCurrentDownloadFilePath);
        debugPrint("Removed current_download_filepath after cleanup attempt.");
      }
    } else {
      debugPrint("No partial file path found in SharedPreferences for cleanup.");
    }
  }

  @override
  void dispose() {
    cancelAllDownloads();
    // Note: Here we don't dispose the AudioDownloadService instances,
    // since they will be disposed after the download is completed/failed/cancelled in _processNextInQueue().
    // And because cancelAllDownloads() was called here, downloads are cancelled, causing _processNextInQueue() to be called again
    super.dispose();
  }
}
