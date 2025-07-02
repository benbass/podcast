import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'notifications_controller.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import '../../application/playback_cubit/playback_cubit.dart';
import '../../domain/entities/podcast_entity.dart';

class UtilitiesNotifications {
  static void initAwesomeNotifications() {
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
          groupKey: NotificationController.notificationGroupKey,
          channelKey: NotificationController.notificationChannelKey,
          channelName: 'Podcast downloading',
          channelDescription:
              'Notification channel for the Podcast Player Downloads',
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
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
      //onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
    );

    ///TODO: Check if user granted permmission for notifications
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  static void cancelNotificationPlayback() {
    AwesomeNotifications().cancel(1);
  }

  static void createNotificationPlayback(
      BuildContext context, bool isPausingState, int position) async {
    final EpisodeEntity episode =
        context.read<PlaybackCubit>().state.episode!;
    final PodcastEntity podcast = episode.podcast.target!;
    final String imageFilePath = podcast.artworkFilePath ?? "";

    // part of string for correct icon depending on boolean provided by the audioHandler methods (playTrack, pauseTrack, resumeTrack...)
    String iconKey = !isPausingState ? 'pause' : 'play';

    // notification state depending on boolean provided by the audioHandler methods (playTrack, pauseTrack, resumeTrack...)
    NotificationPlayState notificationPlayState = isPausingState
        ? NotificationPlayState.paused
        : NotificationPlayState.playing;

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        category: NotificationCategory.Transport,
        title: episode.podcast.target!.title,
        body: episode.title,
        duration: Duration(seconds: episode.duration ?? 0),
        progress: position / (episode.duration ?? 0) * 100,
        playbackSpeed: 1,
        largeIcon: 'file://$imageFilePath',
        bigPicture: 'file://$imageFilePath',
        icon: "resource://drawable/launcher_icon", // App icon
        backgroundColor: const Color(0x00FFFFFF), //Color(0xFFFF8100),
        autoDismissible: false,
        showWhen: false,
        notificationLayout: NotificationLayout.MediaPlayer,
        locked: true,
        playState: notificationPlayState,
        payload: {
          'anything': 'as long as this payload is not null',
        },
      ),
      actionButtons: [
        NotificationActionButton(
            key: 'STOP',
            icon: 'resource://drawable/res_ic_stop',
            label: 'Idle',
            autoDismissible: false,
            showInCompactView: true,
            enabled: true,
            actionType: ActionType.KeepOnTop),
        NotificationActionButton(
            key: 'SKIPPREV',
            icon: 'resource://drawable/res_ic_prev',
            label: 'Previous',
            autoDismissible: false,
            showInCompactView: true,
            enabled: true,
            actionType: ActionType.KeepOnTop),
        NotificationActionButton(
            key: 'SKIPNEXT',
            icon: 'resource://drawable/res_ic_next',
            label: 'Next',
            autoDismissible: false,
            showInCompactView: true,
            enabled: true,
            actionType: ActionType.KeepOnTop),
        NotificationActionButton(
            key: 'RESUMEPAUSE',
            icon: 'resource://drawable/res_ic_$iconKey',
            label: isPausingState ? 'Pause' : 'Play',
            autoDismissible: false,
            showInCompactView: true,
            enabled: true,
            actionType: ActionType.KeepOnTop),
      ],
    );
  }
}
