import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../application/episode_playback/episode_playback_cubit.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../../helpers/player/audiohandler.dart';
import '../../injection.dart';
import '../audioplayer_overlays/audioplayer_overlays.dart';
import '../custom_widgets/failure_widget.dart';
import '../custom_widgets/page_transition.dart';
import 'widgets/subscribed_podcast_card.dart';
import '../podcasts_search_page/podcasts_search_page.dart';

class SubscribedPodcastsHomePage extends StatelessWidget {
  const SubscribedPodcastsHomePage({super.key});

  static const double _spacing = 20.0;

  @override
  Widget build(BuildContext context) {
    // Listen for player state changes (e.g., playing, paused, buffering)
    getIt<MyAudioHandler>().player.playerStateStream.listen((playerState) {
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.completed) {
        getIt<MyAudioHandler>().stop();
        removeOverlay();
        if(context.mounted) {
          BlocProvider.of<EpisodePlaybackCubit>(context).setPlaybackEpisode(null);
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<PodcastBloc, PodcastState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: _spacing),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Podcasts",
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              ScaleRoute(
                                page: const PodcastsSearchPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.search_rounded),
                        ),
                      ],
                    ),
                  ),
                  _buildPodcastGrid(state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPodcastGrid(PodcastState state) {
    // Define the empty state widget
    const emptyStateWidget = SliverToBoxAdapter(
      child: Column(
        children: [
          Icon(
            Icons.arrow_upward_rounded,
            size: 50,
          ),
          Text("Quite empty here!"),
          Text("Search and follow podcasts."),
        ],
      ),
    );

    // Helper function to build the grid
    SliverGrid buildGrid(List<dynamic> podcasts) {
      return SliverGrid.builder(
        itemCount: podcasts.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          crossAxisSpacing: _spacing,
          mainAxisSpacing: _spacing,
        ),
        itemBuilder: (BuildContext context, int index) {
          return SubscribedPodcastCard(
            podcast: podcasts[index],
          );
        },
      );
    }

    Widget buildCircularProgressIndicator() {
      return SliverToBoxAdapter(
          child: Builder(
              builder: (context) => SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      ///TODO: Replace with app logo
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Image.asset("assets/placeholder.png"),
                      ),
                    ),
                  )));
    }

    // Build the grid based on the state
    return state.status == PodcastStatus.loading
        ? buildCircularProgressIndicator()
        : state.status == PodcastStatus.failure
            ? SliverToBoxAdapter(
                child: buildFailureWidget(
                    message: 'Unexpected error. Please restart the app.'),
              )
            : state.subscribedPodcasts.isEmpty
                ? emptyStateWidget
                : buildGrid(state.subscribedPodcasts);
  }
}
