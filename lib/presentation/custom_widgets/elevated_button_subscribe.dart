import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/custom_widgets/page_transition.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../../helpers/core/connectivity_manager.dart';
import '../../injection.dart';
import '../subscribed_podcasts_homepage/subscribed_podcasts_homepage.dart';
import 'failure_dialog.dart';

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
    void subscribeToPodcast() async {
      final String connectionType =
          await getIt<ConnectivityManager>().getConnectionTypeAsString();
      if (connectionType != 'none' && context.mounted) {
        BlocProvider.of<PodcastBloc>(context)
            .add(SubscribeToPodcastEvent(podcast: podcast));
      } else {
        if (context.mounted) {
          showDialog(
              context: context,
              builder: (context) =>
                  const FailureDialog(message: "No internet connection!"));
        }
      }
    }

    return ElevatedButton(
      onPressed: () async {
        !podcast.subscribed
            ? subscribeToPodcast()
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
          return Text(
              state.currentPodcast.subscribed ? "Unsubscribe" : "Subscribe");
        },
      ),
    );
  }
}
