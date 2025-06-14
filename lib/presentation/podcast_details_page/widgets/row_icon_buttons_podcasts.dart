import 'package:flutter/material.dart';
import 'package:podcast/domain/usecases/episode_usecases.dart';
import 'package:share_plus/share_plus.dart';
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

  // This method will be used when the podcast is not subscribed:
  // we need to fetch the episodes from the server before navigating to the EpisodesListPage.
  Future<void> _handleRemoteEpisodesFetchingAndNavigate(
      BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Fetching episodes...'),
              ],
            ),
          );
        });
    try {
      await getIt<EpisodeUseCases>().fetchRemoteEpisodesByFeedIdAndSaveToDb(
          feedId: podcast.pId, podcastTitle: podcast.title);
      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pushAndRemoveUntil(
          ScaleRoute(
            page: const EpisodesListPageWrapper(),
          ),
          ModalRoute.withName('/'),
        );
      }
    } catch (_) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error fetching the episodes")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (podcast.subscribed)
          IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(
              Icons.settings_rounded,
              size: 30,
            ),
          ),
        Row(
          children: [
            Text(
              podcast.episodeCount != null
                  ? podcast.episodeCount.toString()
                  : "",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            IconButton(
              onPressed: () async {
                final String connectionType = await getIt<ConnectivityManager>()
                    .getConnectionTypeAsString();
                if (((connectionType != 'none' && !podcast.subscribed) ||
                        podcast.subscribed) &&
                    context.mounted) {
                  if (podcast.subscribed) {
                    Navigator.of(context).pushAndRemoveUntil(
                      ScaleRoute(
                        page: const EpisodesListPageWrapper(),
                      ),
                      ModalRoute.withName('/'),
                    );
                  } else {
                    _handleRemoteEpisodesFetchingAndNavigate(context);
                  }
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
                size: 30,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () async {
            await SharePlus.instance.share(ShareParams(
              subject: podcast.title,
              text: "${podcast.title}:\n\n ${podcast.link}",
            ));
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
