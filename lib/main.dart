import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';

import 'package:podcast/presentation/homepage/homepage.dart';
import 'package:podcast/theme.dart';
import 'application/episode_playback_url/episode_playback_url_cubit.dart';
import 'application/is_loading/is_loading_cubit.dart';
import 'core/globals.dart';
import 'core/objectbox.dart';
import 'injection.dart' as di;
import 'helpers/notifications/initialize_awesome_notifications.dart';
import 'helpers/player/audiohandler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Init our objectBox
  /* ObjectBox objectbox = await ObjectBox.create();
  podcastBox = objectbox.store.box<PodcastEntity>();
  episodeBox = objectbox.store.box<EpisodeEntity>();*/

  await di.init();
  // Initialize the audio handler and audio service.
  final audioHandler = MyAudioHandler();
  initAwesomeNotifications(audioHandler);

  // Design status and bottom bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF1C0B19), // Color of Status Bar
    statusBarIconBrightness:
        Brightness.light, // Brightness of Icons in Status Bar
    systemNavigationBarColor: Color(0xFF1C0B19), // Color of Bottom Bar
    systemNavigationBarIconBrightness:
        Brightness.dark, // Brightness of Icons in Bottom Bar
  ));

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) => runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (BuildContext context) => EpisodePlaybackUrlCubit()),
          BlocProvider(create: (BuildContext context) => IsLoadingCubit()),
        ],
        // We wrap the app in a SafeArea: on Android API 35, the app doesn't stop
        // at the edge of the bottom bar but at the bottom of the screen,
        // causing some widgets to be partially hidden by the bottom bar.
        // We don't have this issue with API 34, though!
        child: MaterialApp(
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
          home: const HomePage(),
        ),
      ),
    ),
  );
}
