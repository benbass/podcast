import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/presentation/homepage/widgets/search_textfield.dart';
import 'package:podcast/presentation/homepage/widgets/subscribed_podcast_card.dart';

import '../../application/podcasts_bloc/podcasts_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const double _spacing = 20.0;

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<PodcastsBloc>(context).add(GetSubscribedPodcastsEvent());

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Podcasts"),
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          ],
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<PodcastsBloc, PodcastsState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: _spacing),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: _spacing),
                      child: SearchTextField(),
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
    if (state is GotSubscribedPodcastsState) {
      return state.podcasts.isEmpty
          ? emptyStateWidget
          : buildGrid(state.podcasts);
    } else if (state is PodcastsReceivedState) {
      return state.subscribedPodcasts.isEmpty
          ? emptyStateWidget
          : buildGrid(state.subscribedPodcasts);
    } else if (state is PodcastFilledWithEpisodesState) {
      return state.subscribedPodcasts.isEmpty
          ? emptyStateWidget
          : buildGrid(state.subscribedPodcasts);
    } /*else if (state is PodcastIsSubscribedState) {
      return state.subscribedPodcasts.isEmpty
          ? emptyStateWidget
          : buildGrid(state.subscribedPodcasts);
    } else if (state is PodcastIsSubscribedState) {
      return state.subscribedPodcasts.isEmpty
          ? emptyStateWidget
          : buildGrid(state.subscribedPodcasts);
    }*/ else {
      // Handle other states or loading state if needed
      return const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      );
    }
  }
}
