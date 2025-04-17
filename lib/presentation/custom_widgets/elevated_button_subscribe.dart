import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/core/globals.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/custom_widgets/page_transition.dart';
import '../../application/episodes_cubit/episodes_cubit.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
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
            ? subscribeToPodcast(context)
            : unsubscribe(context);
        if (navigate) {
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
  void subscribeToPodcast(BuildContext context) async {
    final String connectionType =
        await getIt<ConnectivityManager>().getConnectionTypeAsString();
    if (connectionType != 'none' && context.mounted) {
      BlocProvider.of<PodcastBloc>(context)
          .add(SubscribeToPodcastEvent(podcast: podcast));
      // We set flag isSubscribed to true
      final episodes = BlocProvider.of<EpisodesCubit>(context).state;
      for (var episode in episodes) {
        episode.isSubscribed = true;
      }
      // We save episodes to db
      episodeBox.putMany(episodes);
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
  deleteUnFlaggedEpisodes() async {
    // We do not just delete the episodes from the db: User may have
    // flagged some episodes and wants to keep them.
    // 1. we set isSubscribed to false for all episodes anyway
    final queryBuilderEpisodes =
        episodeBox.query(EpisodeEntity_.feedId.equals(podcast.pId)).build();
    final resultsA = queryBuilderEpisodes.find();
    for (var ep in resultsA) {
      ep.isSubscribed = false;
      episodeBox.put(ep);
    }

    // 2. We query all ids for episodes with no flag
    final queryBuilderIds = episodeBox
        .query(EpisodeEntity_.feedId
            .equals(podcast.pId)
            .and(EpisodeEntity_.favorite.equals(false))
            .and(EpisodeEntity_.filePath.isNull())
            .and(EpisodeEntity_.position.equals(0)))
        .build();
    final ids = queryBuilderIds.findIds();

    // 3. We delete the episodes in db
    List<int> episodeIds = [];
    for (var id in ids) {
      episodeIds.add(id);
    }
    episodeBox.removeMany(episodeIds);
  }

  void unsubscribe(BuildContext context) async {
    await deleteUnFlaggedEpisodes();
    if (context.mounted) {
      BlocProvider.of<PodcastBloc>(context)
          .add(UnSubscribeFromPodcastEvent(id: podcast.id));
    }
  }
}
