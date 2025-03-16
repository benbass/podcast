import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/core/globals.dart';
import 'package:podcast/domain/entities/episode_entity.dart';

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
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        collapsedHeight: 60,
                        expandedHeight: 170,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: 12,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 80.0),
                                child: Text(
                                  state.podcast!.title,
                                  style:
                                      Theme.of(context).textTheme.displayLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButtonSubscribe(
                                    navigate: true,
                                    podcast: state.podcast!,
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  IconButton(
                                    onPressed: () => Navigator.push(
                                        context,
                                        ScaleRoute(
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
                      StreamBuilder<List<EpisodeEntity>>(
                        // The method getEpisodes checks the subscribed flag of
                        // the podcast and returns the correct stream
                        // (from objectBox database or from the remote server)
                          stream: objectBox.getEpisodes(podcast: state.podcast!, onlyUnread: !state.areReadEpisodesVisible),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SliverFillRemaining(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              // Print the stack trace and show the error message.
                              // An actual app would display a user-friendly error message
                              // and report the error behind the scenes.
                              debugPrintStack(stackTrace: snapshot.stackTrace);
                              return SliverToBoxAdapter(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 60,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16, left: 16, right: 16),
                                      child: Text('Error: ${snapshot.error}'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return SliverPadding(
                                padding: const EdgeInsets.only(bottom: 80.0),
                                sliver: SliverList.builder(
                                  itemCount: snapshot.hasData
                                      ? snapshot.data!.length
                                      : 0,
                                  itemBuilder: (context, index) {
                                    List<EpisodeEntity> episodes =
                                        snapshot.data ?? [];
                                    final item = episodes[index];
                                    return EpisodeCard(
                                      episode: item,
                                      podcast: state.podcast!,
                                    );
                                  },
                                ),
                              );
                            }
                          }),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
