import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import 'package:podcast/helpers/player/audiohandler.dart';
import '../audio_download/audio_download_queue_manager.dart';
import '../../injection.dart';

@pragma("vm:entry-point")
class NotificationController {
  static final NotificationController _instance =
      NotificationController._internal();
  factory NotificationController() => _instance;
  NotificationController._internal();

  static const String notificationChannelKey = "download_channel";
  static const String notificationGroupKey = "download_channel_group'";
  // Keys for action "Show queue"
  static const String showQueueActionKey = "show_download_queue";
  static const String _notificationPayloadActionKey = 'action';
  static const String _showQueueAction = 'show_queue';

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
    } else if (receivedAction.payload?[_notificationPayloadActionKey] ==
            _showQueueAction ||
        receivedAction.buttonKeyPressed == showQueueActionKey) {
      // Also check the buttonKeyPressed for redundancy
      debugPrint("NotificationController: Show Queue action received.");
      // Call the callback in the DownloadQueueManager, if set
      AudioDownloadQueueManager().onShowQueuePage?.call();
    }
  }
}