import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:podcast/presentation/podcast_details_page/widgets/categories.dart';
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
          return SafeArea(
            child: CustomScrollView(
              slivers: [
                FlexibleSpace(
                  podcast: state.podcast,
                  episode: null,
                  title: state.podcast!.title,
                ),
                SliverPadding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 10.0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...state.podcast!.categories.map((value) =>
                              Categories(
                                value: value,
                              )),
                        ],
                      ),
                    )),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 10.0),
                  sliver: SliverToBoxAdapter(
                    child: RowIconButtonsPodcasts(podcast: state.podcast!),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      state.podcast!.description,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 100.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.podcast!.author,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.language,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                state.podcast!.language.toUpperCase(),
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
