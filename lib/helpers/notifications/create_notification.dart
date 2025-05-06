import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:podcast/domain/entities/episode_entity.dart';
import '../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../domain/entities/podcast_entity.dart';

void createNotification(BuildContext context, bool isPausingState, int position) async {
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
        id: 11,
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