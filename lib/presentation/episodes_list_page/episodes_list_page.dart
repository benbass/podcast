import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:podcast/presentation/custom_widgets/elevated_button_subscribe.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/episode_card.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../custom_widgets/page_transition.dart';
import '../podcast_details_page/podcast_details_page.dart';
import 'widgets/row_icon_buttons_episodes.dart';

class EpisodesListPage extends StatelessWidget {
  const EpisodesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PodcastBloc, PodcastState>(
        builder: (context, state) {
          return SafeArea(
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : state.podcast!.episodes.isNotEmpty
                    ? CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverAppBar(
                            collapsedHeight: 60,
                            expandedHeight: 170,
                            pinned: true,
                            flexibleSpace: FlexibleSpaceBar(
                              background: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                spacing: 12,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 80.0),
                                    child: Text(
                                      state.podcast!.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButtonSubscribe(
                                        podcast: state.podcast!,
                                        navigate: true,
                                      ),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      IconButton(
                                        onPressed: () => Navigator.push(
                                            context,
                                            SlideRouteWithCurve(
                                              page: const PodcastDetailsPage(),
                                            )),
                                        icon: const Icon(
                                          Icons.info_outline_rounded,
                                          size: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const RowIconButtonsEpisodes(),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverList.builder(
                            itemCount: state.podcast!.episodes.length,
                            itemBuilder: (context, index) {
                              final item = state.podcast!.episodes[index];
                              return EpisodeCard(
                                item: item,
                                podcast: state.podcast!,
                              );
                            },
                          ),
                          const SliverToBoxAdapter(
                            child: SizedBox(
                              height: 80,
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Text("This podcast has no episodes"),
                      ),
          );
        },
      ),
    );
  }
}
