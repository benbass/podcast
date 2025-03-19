import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/presentation/custom_widgets/failure_widget.dart';

import 'package:podcast/presentation/podcast_details_page/widgets/podcast_category.dart';
import 'package:podcast/presentation/podcast_details_page/widgets/row_icon_buttons_podcasts.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../custom_widgets/flexible_space.dart';

class PodcastDetailsPage extends StatelessWidget {
  const PodcastDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PodcastBloc, PodcastState>(
        builder: (context, state) {
          return state.status == PodcastStatus.loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : state.status == PodcastStatus.failure
                  ? buildFailureWidget(
                      message: "Error loading podcast details.")
                  : SafeArea(
                      child: CustomScrollView(
                        slivers: [
                          FlexibleSpace(
                            podcast: state.currentPodcast,
                            episode: null,
                            title: state.currentPodcast.title,
                          ),
                          SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                  10.0, 0.0, 20.0, 10.0),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...state.currentPodcast.categories
                                        .map((value) => PodcastCategory(
                                              value: value,
                                            )),
                                  ],
                                ),
                              )),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                                40.0, 10.0, 40.0, 10.0),
                            sliver: SliverToBoxAdapter(
                              child: RowIconButtonsPodcasts(
                                  podcast: state.currentPodcast),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 0.0, 20.0, 20.0),
                            sliver: SliverToBoxAdapter(
                              child: Text(
                                state.currentPodcast.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 0.0, 20.0, 100.0),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.currentPodcast.author,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.language,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          state.currentPodcast.language
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
        },
      ),
    );
  }
}
