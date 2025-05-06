import 'package:flutter/material.dart';

import '../../core/globals.dart';
import '../../injection.dart';
import '../database/delete_episodes.dart';
import '../database/delete_podcasts.dart';
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
      deleteEpisodes();
      final bool = deletePodcastsAndArtworkFiles();
      if (!bool) {
        _showErrorDialog("A problem occurred while cleaning the app storage from unneeded data\nWe will try again at the next app closing.");
      }
    }
  }

  void _showErrorDialog(String errorMessage) {
    // We are not in the Widget-tree anymore, so we use the global navigatorKey.
    // We show an Overlay-Dialog over all other widgets.
    navigatorKey.currentState?.overlay?.insert(
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