import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/podcast_bloc/podcast_bloc.dart';
import '../../../domain/entities/podcast_entity.dart';
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

        podcastBloc.add(PodcastTappedEvent(podcast: podcast));
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
        ),
      ),
    );
  }
}
