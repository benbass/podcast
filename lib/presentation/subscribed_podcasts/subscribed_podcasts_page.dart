import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/podcasts_bloc/podcasts_bloc.dart';
import '../custom_widgets/page_transition.dart';
import 'widgets/subscribed_podcast_card.dart';
import '../podcasts_search_page/podcasts_search_page.dart';

class SubscribedPodcastsPage extends StatelessWidget {
  const SubscribedPodcastsPage({super.key});

  static const double _spacing = 20.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<PodcastsBloc, PodcastsState>(
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
                              SlideBottomRoute(
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

  Widget _buildPodcastGrid(PodcastsState state) {
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

    // Build the grid based on the state
    if (state is FetchingSubscribedPodcastsState) {
      return const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (state is SubscribedPodcastsFetchSuccessState) {
      return state.podcasts.isEmpty
          ? emptyStateWidget
          : buildGrid(state.podcasts);
    } else if (state is PodcastsFetchSuccessState) {
      // We handle this state here in case the user navigates back from the results page after a podcast search
      // we still need to show the subscribed podcasts despite state is no more SubscribedPodcastsFetchSuccessState
      return state.subscribedPodcasts.isEmpty
          ? emptyStateWidget
          : buildGrid(state.subscribedPodcasts);
    } else if (state is PodcastFillWithEpisodesSuccessState) {
      // We handle this state here in case the user navigates back from the episodes list page after a podcast search
      // we still need to show the subscribed podcasts despite state is no more SubscribedPodcastsFetchSuccessState
      return state.subscribedPodcasts.isEmpty
          ? emptyStateWidget
          : buildGrid(state.subscribedPodcasts);
    } else if (state is PodcastChangeSubscriptionState) {
      // We handle this state here in case the user navigates back from the episodes list page after he subscribes to a podcast
      // we still need to show the subscribed podcasts despite state is no more SubscribedPodcastsFetchSuccessState
      return state.subscribedPodcasts.isEmpty
          ? emptyStateWidget
          : buildGrid(state.subscribedPodcasts);
    } else {
      return const SliverToBoxAdapter(
        child: Center(child: SizedBox()),
      );
    }
  }
}
