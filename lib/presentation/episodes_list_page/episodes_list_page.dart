import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/domain/entities/episode_entity.dart';
import 'package:podcast/domain/usecases/episode_usecases.dart';
import 'package:podcast/injection.dart';

import 'package:podcast/presentation/custom_widgets/elevated_button_subscribe.dart';
import 'package:podcast/presentation/episodes_list_page/widgets/episode_card_for_list.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../custom_widgets/failure_dialog.dart';
import '../custom_widgets/page_transition.dart';
import '../podcast_details_page/podcast_details_page.dart';
import 'widgets/row_icon_buttons_episodes.dart';

class EpisodesListPage extends StatelessWidget {
  const EpisodesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PodcastBloc, PodcastState>(
      listener: (context, state) {
        if (state.status == PodcastStatus.failure) {
          showDialog(
            context: context,
            builder: (context) => const FailureDialog(
                message: "Error loading episodes. Please try again."),
          ).whenComplete(() {
            if (context.mounted) {
              Navigator.pop(context);
            }
          });
        }
      },
      child: _buildPage(context),
    );
  }

  Scaffold _buildPage(BuildContext context) {
    PodcastState state = context.watch<PodcastBloc>().state;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
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
                      padding: const EdgeInsets.symmetric(horizontal: 80.0),
                      child: Text(
                        state.currentPodcast.title,
                        style: Theme.of(context).textTheme.displayLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButtonSubscribe(
                          navigate: true,
                          podcast: state.currentPodcast,
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
                stream: getIt<EpisodeUseCases>().getEpisodes(
                  subscribed: state.currentPodcast.subscribed,
                  feedId: state.currentPodcast.pId,
                  podcastTitle: state.currentPodcast.title,
                  showRead: state.areReadEpisodesVisible,
                ),
                builder: (context, snapshot) {
                  if (state.status == PodcastStatus.loading) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    return SliverPadding(
                      padding: const EdgeInsets.only(bottom: 80.0),
                      sliver: SliverList.builder(
                        itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                        itemBuilder: (context, index) {
                          List<EpisodeEntity> episodes = snapshot.data ?? [];
                          final item = episodes[index];
                          return EpisodeCardForList(
                            episode: item,
                            podcast: state.currentPodcast,
                          );
                        },
                      ),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}
