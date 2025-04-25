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
import 'package:podcast/presentation/homepage/homepage.dart';
import 'package:podcast/theme.dart';
import 'application/episode_playback_cubit/episode_playback_cubit.dart';
import 'application/episodes_cubit/episodes_cubit.dart';
import 'application/podcast_bloc/podcast_bloc.dart';
import 'application/show_flagged_list/show_flagged_list_cubit.dart';
import 'core/globals.dart';
import 'core/objectbox.dart';
import 'helpers/core/lifecycle_oberserver.dart';
import 'injection.dart' as di;
import 'injection.dart';
import 'helpers/notifications/initialize_awesome_notifications.dart';
import 'helpers/player/audiohandler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  /// Init our objectBox
  objectBox = await ObjectBox.create();
  podcastBox = objectBox.store.box<PodcastEntity>();
  episodeBox = objectBox.store.box<EpisodeEntity>();


  // Initialize the audio handler
  final audioHandler = MyAudioHandler();
  // Initialize the lifecycle observer
  final observer = MyAppLifecycleObserver();
  WidgetsBinding.instance.addObserver(observer);
  // Initialize Awesome Notifications
  initAwesomeNotifications(audioHandler);

  // Design status and bottom bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF202531), // Color of Status Bar
    statusBarIconBrightness:
        Brightness.light, // Brightness of Icons in Status Bar
    systemNavigationBarColor: Color(0xFF202531), // Color of Bottom Bar
    systemNavigationBarIconBrightness:
        Brightness.dark, // Brightness of Icons in Bottom Bar
  ));

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) => runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (BuildContext context) => getIt<EpisodePlaybackCubit>()),
          BlocProvider(
              create: (BuildContext context) => getIt<TextFieldCubit>()),
          BlocProvider(create: (BuildContext context) => getIt<PodcastBloc>()..add(LoadSubscribedPodcastsEvent())),
          BlocProvider(create: (BuildContext context) => getIt<EpisodesCubit>()),
          BlocProvider(create: (BuildContext context) => getIt<ShowFlaggedListCubit>()),
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
