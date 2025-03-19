import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/custom_widgets/page_transition.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../subscribed_podcasts_homepage/subscribed_podcasts_homepage.dart';

class ElevatedButtonSubscribe extends StatelessWidget {
  final PodcastEntity podcast;
  final bool navigate;

  const ElevatedButtonSubscribe({
    super.key,
    required this.podcast,
    required this.navigate,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        !podcast.subscribed
            ? BlocProvider.of<PodcastBloc>(context)
                .add(SubscribeToPodcastEvent(podcast: podcast))
            : BlocProvider.of<PodcastBloc>(context)
                .add(UnSubscribeFromPodcastEvent(id: podcast.id));
        if (navigate) {
          Navigator.push(
            context,
            ScaleRoute(
              page: const SubscribedPodcastsHomePage(),
            ),
          );
        }
      },
      child: BlocBuilder<PodcastBloc, PodcastState>(
        builder: (context, state) {
          return Text(state.currentPodcast.subscribed ? "Unsubscribe" : "Subscribe");
        },
      ),
    );
  }
}
