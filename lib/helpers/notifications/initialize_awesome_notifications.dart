import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:podcast/helpers/player/audiohandler.dart';

import 'notifications_controller.dart';

void initAwesomeNotifications(MyAudioHandler audioHandler) {
  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    null,
    [
      NotificationChannel(
        channelGroupKey: 'basic_channel_group',
        channelKey: 'basic_channel',
        channelName: 'Orange Podcast playing',
        channelDescription: 'Notification channel for the Orange Podcast Player',
        defaultColor: const Color(0xFFFF8100),
        //ledColor: Colors.white,
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

  NotificationController.myAudioHandler = audioHandler; // TODO: Ersetzen durch dependency injection!!!!
  // Only after at least the action method is set, the notification events are delivered
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    /*
    onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
    onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod,
    onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
    */
  );

  ///TODO: Check if user granted permmission for notifications
  AwesomeNotifications().requestPermissionToSendNotifications();

}