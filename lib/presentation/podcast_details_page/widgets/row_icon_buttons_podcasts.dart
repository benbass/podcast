import 'package:flutter/material.dart';
import '../../../domain/entities/podcast_entity.dart';
import '../../../helpers/core/connectivity_manager.dart';
import '../../../injection.dart';
import '../../custom_widgets/dialogs/failure_dialog.dart';
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
              podcast.episodeCount != null
                  ? podcast.episodeCount.toString()
                  : "",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            IconButton(
              onPressed: () async {
                final String connectionType = await getIt<ConnectivityManager>()
                    .getConnectionTypeAsString();
                if (((connectionType != 'none' && !podcast.subscribed) ||
                        podcast.subscribed) &&
                    context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    ScaleRoute(
                      page: const EpisodesListPage(),
                    ),
                    ModalRoute.withName('/'),
                  );
                } else {
                  if (context.mounted) {
                    showDialog(
                        context: context,
                        builder: (context) => const FailureDialog(
                            message:
                                "No internet connection to load episodes from the server!"));
                  }
                }
              },
              icon: const Icon(
                Icons.view_list_rounded,
                size: 40,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.settings_rounded,
            size: 30,
          ),
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
