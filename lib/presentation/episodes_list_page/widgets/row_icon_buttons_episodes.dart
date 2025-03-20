import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/podcast_bloc/podcast_bloc.dart';

class RowIconButtonsEpisodes extends StatelessWidget {
  const RowIconButtonsEpisodes({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final podcastBloc = BlocProvider.of<PodcastBloc>(context);
    return BlocBuilder<PodcastBloc, PodcastState>(
      builder: (context, state) {
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
            if (state.currentPodcast.subscribed)
            IconButton(
              onPressed: () {
                BlocProvider.of<PodcastBloc>(context)
                    .add(RefreshEpisodesByFeedIdEvent(feedId: state.currentPodcast.pId));
              },
              icon: const Icon(
                Icons.refresh_rounded,
                size: 30,
              ),
            ),
            if (state.currentPodcast.subscribed)
              IconButton(
                onPressed: () {
                  podcastBloc.add(
                    ToggleUnreadEpisodesVisibilityEvent(
                      areReadEpisodesVisible: !state.areReadEpisodesVisible,
                    ),
                  );
                },
                icon: Icon(
                  state.areReadEpisodesVisible
                      ? Icons.filter_alt_off_outlined
                      : Icons.filter_alt_outlined,
                  size: 30,
                ),
              ),
          ],
        );
      },
    );
  }
}
