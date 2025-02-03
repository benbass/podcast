import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/application/podcasts_bloc/podcasts_bloc.dart';
import 'package:podcast/presentation/podcast_results_page/widgets/podcast_card.dart';

import '../../domain/entities/podcast_entity.dart';

class PodcastResultsPage extends StatelessWidget {
  const PodcastResultsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: BlocBuilder<PodcastsBloc, PodcastsState>(
          builder: (context, state) {
            return _buildBody(context, state);
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: BlocBuilder<PodcastsBloc, PodcastsState>(
        builder: (context, state) {
          return _buildAppBarTitle(state);
        },
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.home_rounded),
      ),
    );
  }

  Widget _buildAppBarTitle(PodcastsState state) {
    String keyword = "";
    if (state is PodcastsFetchSuccessState) {
      keyword = state.keyword;
    }
    if (state is PodcastFillWithEpisodesSuccessState) {
      keyword = state.keyword;
    }
    final String titleText = "Podcasts for: $keyword";

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(titleText),
    );
  }

  Widget _buildBody(BuildContext context, PodcastsState state) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (state is PodcastsFetchingState)
          _buildLoadingIndicator(context)
        else if (state is PodcastsFetchSuccessState)
          _buildPodcastList(context, state.podcastsQueryResult)
        else if (state is PodcastFillWithEpisodesSuccessState)
          _buildPodcastList(context, state.podcastsQueryResult)
        else if (state is PodcastChangeSubscriptionState)
          _buildPodcastList(context, state.podcastsQueryResult)
        else
          _buildEmptyList(context),
      ],
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildPodcastList(BuildContext context, List<PodcastEntity> podcasts) {
    if (podcasts.isEmpty) {
      return _buildEmptyList(context);
    }
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 80.0),
      sliver: SliverList.builder(
        itemCount: podcasts.length,
        itemBuilder: (context, index) {
          final podcast = podcasts[index];
          return BlocBuilder<PodcastsBloc, PodcastsState>(
            builder: (context, state) {
              return PodcastCard(podcast: podcast);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyList(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("No podcasts were found for your keyword(s)"),
            const SizedBox(height: 16),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
