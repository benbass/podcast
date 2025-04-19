import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/core/globals.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/custom_widgets/page_transition.dart';
import '../../application/episodes_cubit/episodes_cubit.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/usecases/episode_usecases.dart';
import '../../helpers/core/connectivity_manager.dart';
import '../../injection.dart';
import '../../objectbox.g.dart';
import '../homepage/homepage.dart';
import 'failure_dialog.dart';

class ElevatedButtonSubscribe extends StatelessWidget {
  final PodcastEntity podcast;
  final bool navigate;

  const ElevatedButtonSubscribe({
    super.key,
    required this.podcast,
    required this.navigate,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        !podcast.subscribed
            ? await _subscribeToPodcast(context)
            : await _unsubscribe(context);
        if (navigate && context.mounted) {
          Navigator.push(
            context,
            ScaleRoute(
              page: const HomePage(),
            ),
          );
        }
      },
      child: BlocBuilder<PodcastBloc, PodcastState>(
        builder: (context, state) {
          return Text(
              state.currentPodcast.subscribed ? "Unsubscribe" : "Subscribe");
        },
      ),
    );
  }

  /// SUBSCRIBE
  _handleEpisodes(BuildContext context) async {
    // Make sure we have episodes when we subscribe before calling the episode list page
    List<EpisodeEntity> episodes = BlocProvider.of<EpisodesCubit>(context)
        .state
        .where((episode) => episode.feedId == podcast.pId)
        .toList();
    if (episodes.isEmpty) {
      episodes = await getIt<EpisodeUseCases>()
          .getEpisodes(
            subscribed: false,
            feedId: podcast.pId,
            podcastTitle: podcast.title,
            showRead: true,
            refresh: false,
          )
          .first;
    }
    // Set flag isSubscribed to true
    for (var episode in episodes) {
      episode.isSubscribed = true;
    }
    // Save episodes to db
    episodeBox.putMany(episodes);
  }

  _subscribeToPodcast(BuildContext context) async {
    final String connectionType =
        await getIt<ConnectivityManager>().getConnectionTypeAsString();
    if (connectionType != 'none' && context.mounted) {
      BlocProvider.of<PodcastBloc>(context)
          .add(SubscribeToPodcastEvent(podcast: podcast));

      await _handleEpisodes(context);
    } else {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) =>
                const FailureDialog(message: "No internet connection!"));
      }
    }
  }

  /// UNSUBSCRIBE
  _deleteUnFlaggedEpisodes() async {
    // We do not just delete the episodes from the db: User may have
    // flagged some episodes so we  want to keep them.
    // 1. we set isSubscribed to false for all episodes anyway
    final episodesQueryBuilder =
        episodeBox.query(EpisodeEntity_.feedId.equals(podcast.pId)).build();
    final results = episodesQueryBuilder.find();
    for (var ep in results) {
      ep.isSubscribed = false;
      episodeBox.put(ep);
    }

    // 2. We query all ids for episodes with no flag
    final idsQueryBuilder = episodeBox
        .query(EpisodeEntity_.feedId
            .equals(podcast.pId)
            .and(EpisodeEntity_.favorite.equals(false))
            .and(EpisodeEntity_.filePath.isNull())
            .and(EpisodeEntity_.position.equals(0)))
        .build();
    final determinedIds = idsQueryBuilder.findIds();

    // 3. We delete the episodes in db
    episodeBox.removeMany(determinedIds);

  }

  _unsubscribe(BuildContext context) async {
    await _deleteUnFlaggedEpisodes();
    if (context.mounted) {
      BlocProvider.of<PodcastBloc>(context)
          .add(UnSubscribeFromPodcastEvent(id: podcast.id));
    }
  }
}
