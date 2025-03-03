import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/custom_widgets/page_transition.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../subscribed_podcasts/subscribed_podcasts_page.dart';

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
                .add(SubscribeToPodcastEvent())
            : BlocProvider.of<PodcastBloc>(context)
                .add(UnSubscribeFromPodcastEvent());
        if (navigate) {
          Navigator.push(
            context,
            SlideRouteWithCurve(
              page: const SubscribedPodcastsPage(),
            ),
          );
        }
      },
      child: BlocBuilder<PodcastBloc, PodcastState>(
        builder: (context, state) {
          return Text(state.podcast!.subscribed ? "Unsubscribe" : "Subscribe");
        },
      ),
    );
  }
}
