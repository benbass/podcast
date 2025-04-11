import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/presentation/homepage/widgets/scaling_carousel_sliver.dart';

import '../../application/episode_playback_cubit/episode_playback_cubit.dart';
import '../../helpers/listeners/player_listener.dart';
import '../../helpers/listeners/connectivity_listener.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../../injection.dart';
import '../custom_widgets/failure_dialog.dart';
import '../custom_widgets/page_transition.dart';
import '../flagged_episodes_page/flagged_episodes_page.dart';
import '../podcast_details_page/podcast_details_page.dart';
import '../podcasts_search_page/widgets/podcast_card.dart';
import 'widgets/subscribed_podcast_card.dart';
import '../podcasts_search_page/podcasts_search_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const double _spacing = 20.0;

  @override
  Widget build(BuildContext context) {
    // Init listener for player states and Listen for changes (e.g., playing, paused, buffering)
    PlayerStatesListener playerStatesListener = getIt<PlayerStatesListener>();
    // Inject methods to this listener
    // Episode is set to null when and only when player state is completed
    playerStatesListener.setResetPlaybackEpisodeCallback(
        () => context.read<EpisodePlaybackCubit>().setPlaybackEpisode(null));
    // listener needs current playback episode from cubit (initially null)
    playerStatesListener
        .setGetCurrentEpisode(() => context.read<EpisodePlaybackCubit>().state);

    // Listen for connectivity changes
    listenToConnectivity(context);

    return BlocListener<PodcastBloc, PodcastState>(
      listener: (context, state) {
        if (state.status == PodcastStatus.failure) {
          showDialog(
            context: context,
            builder: (context) => const FailureDialog(
                message: "'Unexpected error. Please restart the app."),
          );
        }
      },
      child: _buildPage(context),
    );
  }

  Scaffold _buildPage(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
        appBar: AppBar(title: const Text("Podcasts"), actions: [
          _buildButtons(context),
        ]),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildMainContent(context),
              Padding(
                padding: const EdgeInsets.only(
                    top: _spacing * 0.5, left: _spacing * 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Trending",
                      textAlign: TextAlign.left,
                      style: themeData.textTheme.displayLarge!,
                    ),
                  ],
                ),
              ),
              _buildTrendingPodcasts(context),
              const SizedBox(height: _spacing * 2),
            ],
          ),
        ));
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              ScaleRoute(page: const FlaggedEpisodesPage(flag: "Favorites")),
            );
          },
          icon: const Icon(Icons.star_rounded),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              ScaleRoute(page: const FlaggedEpisodesPage(flag: "Downloads")),
            );
          },
          icon: const Icon(Icons.file_download_outlined),
        ),
        const SizedBox(
          width: 30.0,
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
    );
  }

  Widget _buildTrendingPodcasts(BuildContext context) {
    PodcastState state = context.watch<PodcastBloc>().state;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: _spacing, right: _spacing),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.2,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _spacing),
          child: state.status == PodcastStatus.loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : state.trendingPodcasts.isEmpty
                  ? const SizedBox(
                      child: Text("No trending podcasts found"),
                    )
                  : ScalingCarouselSliver(
                      items: state.trendingPodcasts
                          .map(
                            (e) => InkWell(
                                onTap: () {
                                  context
                                      .read<PodcastBloc>()
                                      .add(PodcastTappedEvent(podcast: e));
                                  Navigator.push(
                                    context,
                                    ScaleRoute(
                                      page: const PodcastDetailsPage(),
                                    ),
                                  );
                                },
                                child: PodcastCard(podcast: e)),
                          )
                          .toList()),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    PodcastState state = context.watch<PodcastBloc>().state;
    // Define the empty state widget
    Widget emptyStateWidget = Padding(
      padding: const EdgeInsets.symmetric(vertical: _spacing*10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: _spacing,
        children: [
          const Text("You have no subscribed podcasts yet"),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: const Row(
              children: [
                Text("Search for podcasts with "),
                Icon(
                  Icons.search_rounded,
                ),
              ],
            ),
          ),

        ],
      ),
    );

    // Helper function to build the grid
    Widget buildGrid(List<dynamic> podcasts) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.55,
        child: Padding(
          padding: const EdgeInsets.all(_spacing),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(2, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(_spacing * 0.5),
              child: GridView.builder(
                itemCount: podcasts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: _spacing*0.5,
                  mainAxisSpacing: _spacing*0.5,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return SubscribedPodcastCard(
                    podcast: podcasts[index],
                  );
                },
              ),
            ),
          ),
        ),
      );
    }

    Widget buildCircularProgressIndicator() {
      return Builder(
          builder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Center(
                  ///TODO: Replace with app logo
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset("assets/placeholder.png"),
                  ),
                ),
              ));
    }

    // Build the grid based on the state
    return state.status == PodcastStatus.loading
        ? buildCircularProgressIndicator()
        : state.subscribedPodcasts.isEmpty
            ? emptyStateWidget
            : buildGrid(state.subscribedPodcasts);
  }
}
