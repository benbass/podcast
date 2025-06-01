import 'package:flutter/material.dart';

// flutter_localizations requires intl 0.19.0 (pinned)
// This leads to incompatibility issue with awesome_notifications 0.10.1 that requires at least intl 0.20.0
// But awesome_notifications 0.10.1 is required after Flutter SDK is updated to version > 3.27
// pubspec.yaml contains a dependency override for intl 0.20.2 as a workaround
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/application/textfield_cubit/text_field_cubit.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/helpers/notifications/notifications_controller.dart';
import 'package:podcast/presentation/audio_download_queue_page/audio_download_queue_page.dart';
import 'package:podcast/presentation/episodes_list_page/episodes_list_page.dart';
import 'package:podcast/presentation/homepage/homepage.dart';
import 'package:podcast/presentation/podcast_details_page/podcast_details_page.dart';
import 'package:podcast/presentation/podcasts_search_page/podcasts_search_page.dart';
import 'package:podcast/theme.dart';
import 'package:provider/provider.dart';
import 'application/episode_playback_cubit/episode_playback_cubit.dart';
import 'application/episode_selection_cubit/episode_selection_cubit.dart';
import 'application/podcast_bloc/podcast_bloc.dart';
import 'core/globals.dart';
import 'core/objectbox.dart';
import 'helpers/audio_download/audio_download_queue_manager.dart';
import 'helpers/core/lifecycle_oberserver.dart';
import 'injection.dart' as di;
import 'injection.dart';
import 'helpers/notifications/utilities_notifications.dart';
import 'helpers/player/audiohandler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  /// Init our objectBox
  objectBox = await ObjectBox.create();
  podcastBox = objectBox.store.box<PodcastEntity>();
  episodeBox = objectBox.store.box<EpisodeEntity>();

  // Initialize the lifecycle observer
  final observer = MyAppLifecycleObserver();
  WidgetsBinding.instance.addObserver(observer);

  // Initialize the audio handler
  MyAudioHandler();
  // Initialize Awesome Notifications
  UtilitiesNotifications.initAwesomeNotifications();
  // Initialize the notification controller
  NotificationController();
  // Initialize the Queue Manager
  final audioDownloadQueueManager = AudioDownloadQueueManager();

  await AudioDownloadQueueManager.cleanupLastPartialDownload();

  // Set the callback for the "Show Queue" action in the notification
  audioDownloadQueueManager.onShowQueuePage = () {
    MyApp.navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const AudioDownloadQueuePage()));
  };

  // Design status and bottom bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF050921), // Color of Status Bar
      statusBarIconBrightness:
          Brightness.light, // Brightness of Icons in Status Bar
      systemNavigationBarColor: Color(0xFF050921), // Color of Bottom Bar
      systemNavigationBarIconBrightness:
          Brightness.dark, // Brightness of Icons in Bottom Bar
    ),
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) => runApp(
      ChangeNotifierProvider(
        create: (_) => audioDownloadQueueManager,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (BuildContext context) =>
                    getIt<EpisodeSelectionCubit>()),
            BlocProvider(
                create: (BuildContext context) =>
                    getIt<EpisodePlaybackCubit>()),
            BlocProvider(
                create: (BuildContext context) => getIt<TextFieldCubit>()),
            BlocProvider(
                create: (BuildContext context) =>
                    getIt<PodcastBloc>()..add(LoadSubscribedPodcastsEvent())),
          ],
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('de', 'DE'),
        Locale('fr', 'FR'),
      ],
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/podcastDetails': (context) => const PodcastDetailsPage(),
        '/podcastSearch': (context) => const PodcastsSearchPage(),
        '/episodesList': (context) => const EpisodesListPage(),
      },
    );
  }
}
