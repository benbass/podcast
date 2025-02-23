import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/podcast_bloc/podcast_bloc.dart';
import '../../../domain/entities/podcast_entity.dart';
import '../../custom_widgets/page_transition.dart';
import '../../episodes_list_page/episodes_list_page.dart';

class RowIconButtonsPodcasts extends StatelessWidget {
  const RowIconButtonsPodcasts({
    super.key,
    required this.podcast,
  });

  final PodcastEntity podcast;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              podcast.episodeCount.toString(),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            IconButton(
              onPressed: () {
                BlocProvider.of<PodcastBloc>(context).add(
                  FetchEpisodesForPodcastProcessingEvent(podcast: podcast),
                );
                Navigator.push(
                  context,
                  SlideBottomRoute(
                    page: Builder(builder: (context) {
                      return const EpisodesListPage();
                    }),
                  ),
                );
              },
              icon: const Icon(
                Icons.view_list_rounded,
                size: 40,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            // share podcast link
          },
          icon: const Icon(
            Icons.share_rounded,
            size: 30,
          ),
        ),
      ],
    );
  }
}
