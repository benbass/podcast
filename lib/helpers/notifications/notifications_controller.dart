import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:podcast/helpers/player/audiohandler.dart';

class NotificationController {
  static MyAudioHandler? myAudioHandler;
/*
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here
  }
*/
  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    if (receivedAction.buttonKeyPressed == 'SKIPPREV') {
      //di.sl<PlayerControlsBloc>().add(PreviousButtonInNotificationPressed());
    } else if (receivedAction.buttonKeyPressed == 'RESUMEPAUSE') {
      NotificationController.myAudioHandler!.player.playerState.playing ?
      NotificationController.myAudioHandler?.pause() : NotificationController.myAudioHandler?.play();
    }
    else if (receivedAction.buttonKeyPressed == 'SKIPNEXT') {
      //di.sl<PlayerControlsBloc>().add(NextButtonInNotificationPressed());
    }
    else if (receivedAction.buttonKeyPressed == 'STOP') {
      NotificationController.myAudioHandler?.stop();
    }

  }

}