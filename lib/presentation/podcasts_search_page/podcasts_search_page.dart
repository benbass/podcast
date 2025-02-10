import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/application/podcasts_bloc/podcasts_bloc.dart';
import 'package:podcast/presentation/podcasts_search_page/widgets/podcast_card.dart';

import '../../domain/entities/podcast_entity.dart';
import '../custom_widgets/page_transition.dart';
import 'widgets/search_textfield.dart';
import '../subscribed_podcasts/subscribed_podcasts_page.dart';

class PodcastsSearchPage extends StatelessWidget {
  const PodcastsSearchPage({
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
      title: const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: SearchTextField(),
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            SlideBottomRoute(
              page: const SubscribedPodcastsPage(),
            ),
          );
        },
        icon: const Icon(Icons.home_rounded),
      ),
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
          const SliverToBoxAdapter(),
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
    return const SliverFillRemaining(
      child: Center(
        child: Text("No podcasts were found for your keyword(s)"),
      ),
    );
  }
}
