import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'notifications_controller.dart';

void initAwesomeNotifications() {
  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    null,
    [
      NotificationChannel(
        channelGroupKey: 'basic_channel_group',
        channelKey: 'basic_channel',
        channelName: 'Podcast playing',
        channelDescription: 'Notification channel for the Podcast Player',
        defaultColor: const Color(0xFFFF8100),
        playSound: false,
        enableVibration: false,
        importance: NotificationImportance.High,
        channelShowBadge: false,
        locked: true,
        defaultPrivacy: NotificationPrivacy.Public,
        icon: "resource://drawable/launcher_icon",
      ),
      NotificationChannel(
        groupKey: 'basic_channel_group',
        channelGroupKey: 'basic_channel_group',
        channelKey: 'progress_channel',
        channelName: 'Podcast downloading',
        channelDescription: 'Notification channel for the Podcast Player Downloads',
        defaultColor: const Color(0xFFFF8100),
        playSound: false,
        enableVibration: false,
        importance: NotificationImportance.High,
        channelShowBadge: false,
        locked: true,
        defaultPrivacy: NotificationPrivacy.Public,
        icon: "resource://drawable/launcher_icon",
      )
    ],
    // debug: true,
  );

  // Only after at least the action method is set, the notification events are delivered
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    //onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
    onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod,
    //onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
  );

  ///TODO: Check if user granted permmission for notifications
  AwesomeNotifications().requestPermissionToSendNotifications();

}