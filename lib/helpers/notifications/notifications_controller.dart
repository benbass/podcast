import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import 'package:podcast/helpers/player/audiohandler.dart';
import '../../injection.dart';
import '../audio_download/audio_download_service.dart';
import 'utilities_notifications.dart';

@pragma("vm:entry-point")
class NotificationController {
  static final NotificationController _instance =
      NotificationController._internal();
  factory NotificationController() => _instance;
  NotificationController._internal();

  // Map to save the AudioDownloadService instances by notificationId
  final Map<int, AudioDownloadService> activeDownloads = {};

  // Method to register a AudioDownloadService instance
  void registerDownload(
      int notificationId, AudioDownloadService audioDownloadService) {
    activeDownloads[notificationId] = audioDownloadService;
    debugPrint("Download registered with id: $notificationId");
  }

  // Method to unregister a AudioDownloadService instance
  void unregisterDownload(int notificationId) {
    activeDownloads.remove(notificationId);
    UtilitiesNotifications.cancelNotificationDownload(notificationId);
    debugPrint("Download unregistered with id: $notificationId");
  }

  void _cancelDownload(int notificationId, String savePath) {
    final AudioDownloadService? audioDownloadService =
        activeDownloads[notificationId];
    if (audioDownloadService != null) {
      audioDownloadService.cancelDownload(savePath);
      unregisterDownload(notificationId);
    }
  }

/*
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationCreated: ${receivedNotification.id}');
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationDisplayed: ${receivedNotification.id}');
  }
*/

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onDismissActionReceived: ${receivedAction.id}');
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.buttonKeyPressed == 'SKIPPREV') {
      // to be implemented
    } else if (receivedAction.buttonKeyPressed == 'RESUMEPAUSE') {
      getIt<MyAudioHandler>().handlePlayPause();
    } else if (receivedAction.buttonKeyPressed == 'SKIPNEXT') {
      // to be implemented
    } else if (receivedAction.buttonKeyPressed == 'STOP') {
      getIt<MyAudioHandler>().stop();
    } else if (receivedAction.buttonKeyPressed == 'CANCEL') {
      final String? notificationIdString =
          receivedAction.payload?['notificationId'];
      final String? savePath = receivedAction.payload?['savePath'];
      if (notificationIdString != null && savePath != null) {
        try {
          final int notificationId = int.parse(notificationIdString);
          NotificationController()._cancelDownload(notificationId, savePath);
        } catch (e) {
          debugPrint("Error parsing notificationId: $e");
        }
      }
    }
  }
}
