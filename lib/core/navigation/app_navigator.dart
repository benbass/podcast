import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/episodes/episodes_bloc/episodes_bloc.dart';
import '../../application/playback/playback_cubit/playback_cubit.dart';
import '../../application/podcast/podcast_bloc/podcast_bloc.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/podcast_entity.dart';
import '../../domain/entities/podcast_filter_settings_entity.dart';
import '../../main.dart';
import '../../presentation/episode_details_page/episode_details_page.dart';

class AppNavigator {
  // The EpisodeDetailsPage is a PageView depending on a specific list of episodes.
  // If user called a different podcast after tapping on Play, the episode being played doesn't exist for this podcast.
  /// Reset the PodcastBloc state with the podcast the playback episode belongs to and the EpisodesBloc state with the correct episode list.
  /// Then navigate to the EpisodeDetailsPage.
  static void navigateToEpisodeDetailsFromGlobalAction() {
    final BuildContext? context = MyApp.navigatorKey.currentContext;
    if (context == null) return;

    EpisodeEntity episode =
        BlocProvider.of<PlaybackCubit>(context, listen: false)
            .state
            .episode!;
    List<EpisodeEntity> episodes =
        BlocProvider.of<PlaybackCubit>(context, listen: false)
            .state
            .currentPlaylist;
    PodcastEntity podcast = episode.podcast.target!;
    PodcastFilterSettingsEntity settings =
        podcast.persistentSettings.target!.toFilterSettings();

    BlocProvider.of<EpisodesBloc>(context).add(LoadEpisodes(
      feedId: podcast.feedId,
      isSubscribed: podcast.subscribed,
      initialFilterSettings: settings,
    ));

    final podcastBloc = BlocProvider.of<PodcastBloc>(context);
    podcastBloc.add(PodcastSelectedEvent(podcast: podcast));

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => EpisodeDetailsPage(
          initialEpisode: episode,
          episodes: episodes,
        ),
      ),
    );
  }
}
