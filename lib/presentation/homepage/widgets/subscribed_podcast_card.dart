import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/podcast_bloc/podcast_bloc.dart';
import '../../../domain/entities/podcast_entity.dart';
import '../../../domain/usecases/episode_usecases.dart';
import '../../../injection.dart';
import '../../custom_widgets/page_transition.dart';
import '../../episodes_list_page/episodes_list_page.dart';

class SubscribedPodcastCard extends StatelessWidget {
  final PodcastEntity podcast;
  const SubscribedPodcastCard({
    super.key,
    required this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    final podcastBloc = BlocProvider.of<PodcastBloc>(context);
    return InkResponse(
      onTap: () {
        //context.read<PodcastSettingsCubit>().loadSettings(podcast.id);

        podcastBloc.add(PodcastSelectedEvent(podcast: podcast));
        Navigator.push(
          context,
          ScaleRoute(
            page: const EpisodesListPageWrapper(),
          ),
        );
      },
      child: Material(
        elevation: 16,
        borderRadius: BorderRadius.circular(15),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: podcast.artworkFilePath != null
                  ? FileImage(File(podcast.artworkFilePath!))
                  : const AssetImage('assets/placeholder.png'),
              fit: BoxFit.fitHeight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 2.0,
                right: 2.0,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: StreamBuilder<int>(
                    stream: getIt<EpisodeUseCases>()
                        .unreadLocalEpisodesCount(feedId: podcast.feedId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final unreadEpisodesCount = snapshot.data;
                        return Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.onPrimary),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            unreadEpisodesCount.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
