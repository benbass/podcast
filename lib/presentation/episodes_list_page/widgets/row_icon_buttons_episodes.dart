import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/podcast_bloc/podcast_bloc.dart';

class RowIconButtonsEpisodes extends StatelessWidget {
  const RowIconButtonsEpisodes({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: () {
            // full text search
          },
          icon: const Icon(
            Icons.search_rounded,
            size: 30,
          ),
        ),
        IconButton(
          onPressed: () {
            // activate select on list items
          },
          icon: const Icon(
            Icons.select_all_rounded,
            size: 30,
          ),
        ),
        IconButton(
          onPressed: () {
            BlocProvider.of<PodcastBloc>(context).add(RefreshPodcastEpisodesProcessingEvent());
          },
          icon: const Icon(
            Icons.refresh_rounded,
            size: 30,
          ),
        ),
      ],
    );
  }
}