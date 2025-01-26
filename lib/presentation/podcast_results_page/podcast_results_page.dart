import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/application/podcasts_bloc/podcasts_bloc.dart';
import 'package:podcast/presentation/podcast_results_page/widgets/podcast_card.dart';

class PodcastResultsPage extends StatelessWidget {
  const PodcastResultsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<PodcastsBloc, PodcastsState>(
          builder: (context, state) {
            if (state is PodcastsReceivedState) {
              return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Podcasts for: ${state.keyword}",
                  ));
            } else {
              return const Text("");
            }
          },
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.home_rounded),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<PodcastsBloc, PodcastsState>(
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                if (state is PodcastsFetchingState)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                if (state is PodcastsReceivedState)
                  if (state.podcasts.isNotEmpty)
                    SliverPadding(
                      // Padding will prevent last item to be hidden when overlay (mini player) is shown
                      padding: const EdgeInsets.only(bottom: 80.0),
                      sliver: SliverList.builder(
                        itemCount: state.podcasts.length,
                        itemBuilder: (context, index) {
                          final podcast = state.podcasts.elementAt(index);
                          return PodcastCard(
                            podcast: podcast,
                          );
                        },
                      ),
                    )
                  else
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          children: [
                            const Spacer(),
                            const Text(
                                "No podcasts were found for your keyword(s)"),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 36,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
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
