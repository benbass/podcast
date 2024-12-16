import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';

void createNotification(bool isPausingState) async {

    // part of string for correct icon depending on boolean provided by the audioHandler methods (playTrack, pauseTrack, resumeTrack...)
    String iconKey = !isPausingState ? 'pause' : 'play';

    // notification state depending on boolean provided by the audioHandler methods (playTrack, pauseTrack, resumeTrack...)
    NotificationPlayState notificationPlayState = isPausingState
        ? NotificationPlayState.paused
        : NotificationPlayState.playing;

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        category: NotificationCategory.Transport,
        title: "currentTrack.trackName",
        body: "currentTrack.trackArtistNames",
        playbackSpeed: 1,

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