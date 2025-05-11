import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'notifications_controller.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:podcast/domain/entities/episode_entity.dart';
import '../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../domain/entities/podcast_entity.dart';

class UtilitiesNotifications{
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

  static void cancelNotificationDownload(notificationId) {
    AwesomeNotifications().cancel(notificationId);
  }

  static void cancelNotificationPlayback() {
    AwesomeNotifications().cancel(1);
  }

  static void createNotificationDownload(double progress, String savePath, String episodeTitle, int notificationId) async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'progress_channel',
        category: NotificationCategory.Progress,
        notificationLayout: NotificationLayout.ProgressBar,
        title: 'Downloading episode',
        body: episodeTitle,
        progress: progress,
        autoDismissible: true,
        showWhen: false,
        locked: true,
        backgroundColor: const Color(0x00FFFFFF),
        payload: {
          'savePath': savePath,
          'notificationId': notificationId.toString(),},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'CANCEL',
          label: 'Cancel download',
          autoDismissible: false,
          showInCompactView: true,
          enabled: true,
          isDangerousOption: true,
          actionType: ActionType.KeepOnTop,
        ),
      ],
    );
  }

  static void createNotificationPlayback(BuildContext context, bool isPausingState, int position) async {
    final EpisodeEntity episode = context.read<EpisodePlaybackCubit>().state!.values.first;
    final PodcastEntity podcast = context.read<EpisodePlaybackCubit>().state!.keys.first;
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
        title: episode.podcastTitle,
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
            label:
            isPausingState ? 'Pause' : 'Play',
            autoDismissible: false,
            showInCompactView: true,
            enabled: true,
            actionType: ActionType.KeepOnTop),
      ],
    );
  }
}
