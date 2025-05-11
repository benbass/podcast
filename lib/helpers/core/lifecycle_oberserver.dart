import 'package:flutter/material.dart';
import 'package:podcast/helpers/audio_download/audio_download_service.dart';

import '../../injection.dart';
import '../../main.dart';
import '../database/episode_cleanup.dart';
import '../database/unsubscribed_podcast_cleanup.dart';
import '../notifications/notifications_controller.dart';
import '../player/audiohandler.dart';
import 'connectivity_manager.dart';

class MyAppLifecycleObserver extends WidgetsBindingObserver {

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      // App is being closed
      getIt<MyAudioHandler>().dispose();
      getIt<ConnectivityManager>().dispose();
      // Clean database from objects related to unsubscribed podcasts
      EpisodeCleanup.deleteEpisodes();
      final bool = UnsubscribedPodcastCleanup.deletePodcastsAndArtworkFiles();
      if (!bool) {
        _showErrorDialog("A problem occurred while cleaning the app storage from unneeded data\nWe will try again at the next app closing.");
      }
      final Map<int, AudioDownloadService> notifications = NotificationController().activeDownloads;
      if (notifications.isNotEmpty) {
        notifications.forEach((notificationId, audioDownloadService) {
          audioDownloadService.dispose();
        });
      }
    }
  }

  void _showErrorDialog(String errorMessage) {
    // We are not in the Widget-tree anymore, so we use the global navigatorKey.
    // We show an Overlay-Dialog over all other widgets.
    MyApp.navigatorKey.currentState?.overlay?.insert(
      OverlayEntry(
        builder: (context) => AlertDialog(
          title: const Text('Error!'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}