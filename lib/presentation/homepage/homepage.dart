import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/presentation/homepage/widgets/search_textfield.dart';

import '../../application/podcasts_bloc/podcasts_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<PodcastsBloc>(context)
        .add(SubscribedPodcastsLoadingEvent());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Podcasts"),
      ),
      body: SafeArea(
        child: BlocBuilder<PodcastsBloc, PodcastsState>(
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                    child: SearchTextField(),
                  ),
                ),
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
                      : const SliverToBoxAdapter(child: SizedBox.shrink()),
                // Loader while we fetch podcasts
                if (state is PodcastsFetchingState)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
