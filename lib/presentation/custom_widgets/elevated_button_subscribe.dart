import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/custom_widgets/page_transition.dart';
import '../../application/podcasts_bloc/podcasts_bloc.dart';
import '../homepage/homepage.dart';

class ElevatedButtonSubscribe extends StatelessWidget {
  final PodcastEntity podcast;
  final bool navigate;
  const ElevatedButtonSubscribe({super.key, required this.podcast, required this.navigate});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        !podcast.subscribed
            ? BlocProvider.of<PodcastsBloc>(context)
                .add(SubscribeToPodcastEvent(podcast: podcast))
            : BlocProvider.of<PodcastsBloc>(context)
                .add(UnsubscribeFromPodcastEvent(podcast: podcast));
        if (navigate) {
          Navigator.push(
            context,
            SlideBottomRoute(
              page: const HomePage(),
            ),
          );
        }
      },
      child: Text(podcast.subscribed ? "Unsubscribe" : "Subscribe"),
    );
  }
}
