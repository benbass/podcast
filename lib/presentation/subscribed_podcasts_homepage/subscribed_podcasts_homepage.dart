import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../helpers/listeners/player_listener.dart';
import '../../helpers/listeners/connectivity_listener.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../custom_widgets/failure_dialog.dart';
import '../custom_widgets/page_transition.dart';
import '../flagged_episodes_page/flagged_episodes_page.dart';
import 'widgets/subscribed_podcast_card.dart';
import '../podcasts_search_page/podcasts_search_page.dart';

class SubscribedPodcastsHomePage extends StatelessWidget {
  const SubscribedPodcastsHomePage({super.key});

  static const double _spacing = 20.0;

  @override
  Widget build(BuildContext context) {
    // Listen for player state changes (e.g., playing, paused, buffering)
    listenToPlayer(context);
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
    return Scaffold(
        body: SafeArea(
      child: Padding(
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
            _buildButtons(context),
            _buildMainContent(context),
          ],
        ),
      ),
    ));
  }

  Widget _buildButtons(BuildContext context) {
    return SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: _spacing*2),
        sliver: SliverToBoxAdapter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    ScaleRoute(
                      page: const FlaggedEpisodesPage(flag: "Favorites")
                    ),
                  );
                },
                child: const Text("Favourites"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    ScaleRoute(
                        page: const FlaggedEpisodesPage(flag: "Downloads")
                    ),
                  );
                },
                child: const Text("Downloads"),
              ),
            ],
          ),
        ));
  }

  Widget _buildMainContent(BuildContext context) {
    PodcastState state = context.watch<PodcastBloc>().state;
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
        : state.subscribedPodcasts.isEmpty
            ? emptyStateWidget
            : buildGrid(state.subscribedPodcasts);
  }
}
