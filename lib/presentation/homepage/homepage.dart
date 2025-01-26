import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/presentation/homepage/widgets/search_textfield.dart';
import 'package:podcast/presentation/homepage/widgets/subscribed_podcast_card.dart';

import '../../application/subscribed_podcasts_bloc/subscribed_podcasts_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const double _spacing = 20.0;

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<SubscribedPodcastsBloc>(context)
        .add(SubscribedPodcastsLoadingEvent());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Podcasts"),
      ),
      body: SafeArea(
        child: BlocBuilder<SubscribedPodcastsBloc, SubscribedPodcastsState>(
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
                  // Loader while we get subscribed (local) podcasts
                  if (state is SubscribedPodcastsLoadingState)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (state is SubscribedPodcastsLoadedState)
                    state.subscribedPodcasts.isEmpty
                        ? const SliverToBoxAdapter(
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
                          )
                        : SliverGrid.builder(
                            itemCount: state.subscribedPodcasts.length,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              crossAxisSpacing: _spacing,
                              mainAxisSpacing: _spacing,
                              //childAspectRatio: 4 / 5,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return SubscribedPodcastCard(
                                subscribedPodcast:
                                    state.subscribedPodcasts[index],
                              );
                            },
                          ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
