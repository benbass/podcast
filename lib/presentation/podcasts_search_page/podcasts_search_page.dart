import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/presentation/custom_widgets/home_button.dart';
import 'package:podcast/presentation/podcasts_search_page/widgets/podcast_card.dart';

import '../../application/podcast_bloc/podcast_bloc.dart';
import '../../application/textfield_cubit/text_field_cubit.dart';
import '../custom_widgets/dialogs/failure_dialog.dart';
import '../custom_widgets/page_transition.dart';
import '../podcast_details_page/podcast_details_page.dart';
import 'widgets/search_textfield.dart';

class PodcastsSearchPage extends StatelessWidget {
  const PodcastsSearchPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final podcastBloc = BlocProvider.of<PodcastBloc>(context);
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: BlocBuilder<PodcastBloc, PodcastState>(
          builder: (context, state) {
            return _buildBody(context, state, podcastBloc);
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
        leading: const MyHomeButton());
  }

  Widget _buildBody(
      BuildContext context, PodcastState state, Bloc podcastBloc) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: state.status == PodcastStatus.loading
            ? _buildLoadingIndicator(context)
            : state.status == PodcastStatus.failure
                ? const FailureDialog(
                    message: "Error loading podcasts",
                  )
                : _buildPodcastList(context, state, podcastBloc),
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildPodcastList(
      BuildContext context, PodcastState state, Bloc podcastBloc) {
    if (context.read<TextFieldCubit>().state == null) {
      return _buildEmptyList(
          context, "Enter keyword(s) to\nsearch for podcasts");
    } else {
      if (state.queryResultPodcasts.isEmpty && context.read<TextFieldCubit>().state != null) {
        return _buildEmptyList(
            context, "No podcasts found\nfor your keyword(s)");
      } else {
        return CarouselView(
          itemExtent: MediaQuery.of(context).size.width,
          scrollDirection: Axis.vertical,
          itemSnapping: true,
          padding: const EdgeInsets.all(10.0),
          backgroundColor:
              Colors.transparent, //Theme.of(context).colorScheme.secondary,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: const BorderSide(
              color: Colors.transparent,
              width: 0.0,
            ),
          ),
          onTap: (index) async {
            podcastBloc.add(
                PodcastSelectedEvent(podcast: state.queryResultPodcasts[index]));
            if(context.mounted) {
              Navigator.push(
              context,
              ScaleRoute(
                page: const PodcastDetailsPage(),
              ),
            );
            }
          },
          children: List.generate(
            state.queryResultPodcasts.length,
            (index) {
              final podcast = state.queryResultPodcasts[index];
              return PodcastCard(podcast: podcast);
            },
          ),
        );
      }
    }
  }

  Widget _buildEmptyList(BuildContext context, String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, height: 1.7),
        textAlign: TextAlign.center,
      ),
    );
  }
}
