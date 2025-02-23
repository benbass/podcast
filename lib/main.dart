import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';

import 'package:podcast/presentation/homepage/homepage.dart';
import 'package:podcast/theme.dart';
import 'application/episode_playback_url/episode_playback_url_cubit.dart';
import 'application/podcast_bloc/podcast_bloc.dart';
import 'core/globals.dart';
import 'core/objectbox.dart';
import 'injection.dart' as di;
import 'injection.dart';
import 'helpers/notifications/initialize_awesome_notifications.dart';
import 'helpers/player/audiohandler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  /// Init our objectBox
  ObjectBox objectBox = await ObjectBox.create();
  podcastBox = objectBox.store.box<PodcastEntity>();
  episodeBox = objectBox.store.box<EpisodeEntity>();


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
          BlocProvider(create: (BuildContext context) => getItI<PodcastBloc>()..add(SubscribedPodcastsLoadingEvent())),
          //BlocProvider(create: (BuildContext context) => getItI<EpisodesBloc>()),
        ],
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
