import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/presentation/custom_widgets/home_button.dart';
import 'package:podcast/presentation/podcasts_search_page/widgets/podcast_card.dart';

import '../../application/podcast_bloc/podcast_bloc.dart';
import 'widgets/search_textfield.dart';

class PodcastsSearchPage extends StatelessWidget {
  const PodcastsSearchPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: BlocBuilder<PodcastBloc, PodcastState>(
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
      leading: const MyHomeButton()
    );
  }

  Widget _buildBody(BuildContext context, PodcastState state) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (state.loading)
          _buildLoadingIndicator(context)
        else
          _buildPodcastList(context, state)
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

  Widget _buildPodcastList(BuildContext context, PodcastState state) {
    if (state.keyword == null) {
      return _buildEmptyList(context, "Enter keyword(s) to\nsearch for podcasts");
    }
    if (state.podcastsQueryResult.isEmpty && state.keyword != null) {
      return _buildEmptyList(context, "No podcasts found\nfor your keyword(s)");
    }
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 80.0),
      sliver: SliverList.builder(
        itemCount: state.podcastsQueryResult.length,
        itemBuilder: (context, index) {
          final podcast = state.podcastsQueryResult[index];
          return BlocBuilder<PodcastBloc, PodcastState>(
            builder: (context, state) {
              return PodcastCard(podcast: podcast);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyList(BuildContext context, String text) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 20, height: 1.7),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
