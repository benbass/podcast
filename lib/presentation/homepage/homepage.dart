
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/presentation/homepage/widgets/scaling_carousel_sliver.dart';

import '../../application/playback_cubit/playback_cubit.dart';
import '../../domain/queued_audio_download/queued_audio_download.dart';
import '../../helpers/audio_download/audio_download_queue_manager.dart';
import '../../helpers/listeners/player_listener.dart';
import '../custom_widgets/decoration/box_decoration.dart';
import '../custom_widgets/dialogs/connectivity_dialogs.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../../injection.dart';
import '../custom_widgets/dialogs/failure_dialog.dart';
import '../custom_widgets/effects/backdropfilter.dart';
import '../custom_widgets/page_transition.dart';
import '../episodes_list_page/widgets/animated_download_icon.dart';
import '../playlist/playlist_page.dart';
import '../podcast_details_page/podcast_details_page.dart';
import '../podcasts_search_page/widgets/podcast_card.dart';
import 'widgets/subscribed_podcast_card.dart';
import '../podcasts_search_page/podcasts_search_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const double _spacing = 20.0;

  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    final downloadManager = AudioDownloadQueueManager();

    final bool hasActiveDownloads = downloadManager.downloadItems.any((item) =>
        item.status == DownloadStatus.downloading ||
        item.status == DownloadStatus.pending);

    if (hasActiveDownloads) {
      final bool? shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => Stack(
          children: [
            const BackdropFilterWidget(sigma: 4.0),
            AlertDialog(
              title: const Text('Downloads aktiv'),
              content: const Text(
                  'Downloads are still running or downloads are waiting in the queue. Do you really want to close the app? The downloads will be cancelled.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Close the app'),
                ),
              ],
            ),
          ],
        ),
      );

      if (shouldPop == true) {
        // User confirmed the exit, close the app
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      } else {
        // Do nothing, user canceled the app closing.
      }
    } else {
      final bool? shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => Stack(
          children: [
            const BackdropFilterWidget(sigma: 4.0),
            AlertDialog(
              title: const Text('Do you really want to close the app?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Close the app'),
                ),
              ],
            ),
          ],
        ),
      );
      if (shouldPop == true) {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    // Init listener for player states and Listen for changes (e.g., playing, paused, buffering)
    PlayerStatesListener playerStatesListener = getIt<PlayerStatesListener>();
    // Inject methods to this listener
    playerStatesListener.setGetCurrentEpisode(
        () => context.read<PlaybackCubit>().state.episode);
    playerStatesListener.setGetAutoplayStatus(() => context.read<PlaybackCubit>().state.isAutoplayEnabled);

    // Listen for connectivity changes
    ConnectivityDialog.showConnectivityDialogs(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _showExitConfirmationDialog(context);
        }
      },
      child: BlocListener<PodcastBloc, PodcastState>(
        listener: (context, state) {
          if (state.status == PodcastStatus.failure) {
            showDialog(
              context: context,
              builder: (context) => const FailureDialog(
                  message: "'Unexpected error. Please restart the app."),
            );
          }
        },
        child: _buildPage(context),
      ),
    );
  }

  Scaffold _buildPage(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //title: const Text("Podcasts"),
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                ScaleRoute(
                  page: const PlaylistPage(),
                ),
              );
            },
            icon: const Icon(Icons.featured_play_list_rounded),
          ),
          actions: [
            _buildButtons(context),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildMainContent(context),
              _buildTrendingPodcasts(context),
            ],
          ),
        ));
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        const AnimatedDownloadIcon(),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              ScaleRoute(
                page: const PodcastsSearchPage(),
              ),
            );
          },
          icon: const Icon(Icons.search_rounded),
        ),
      ],
    );
  }

  Widget _buildTrendingPodcasts(BuildContext context) {
    final themeData = Theme.of(context);
    PodcastState state = context.watch<PodcastBloc>().state;
    return Padding(
      padding: const EdgeInsets.fromLTRB(_spacing, 8.0, _spacing, 140.0),
      child: Container(
        decoration: buildBoxDecoration(context),
        child: state.status == PodcastStatus.loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : state.trendingPodcasts.isEmpty
                ? const SizedBox(
                    child: Text("No trending podcasts found"),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Trending",
                          style: themeData.textTheme.displayLarge!,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ScalingCarouselSliver(
                            items: state.trendingPodcasts
                                .map(
                                  (e) => InkWell(
                                      onTap: () async {
                                        if (context.mounted) {
                                          context.read<PodcastBloc>().add(
                                              PodcastSelectedEvent(podcast: e));
                                          Navigator.push(
                                            context,
                                            ScaleRoute(
                                              page: const PodcastDetailsPage(),
                                            ),
                                          );
                                        }
                                      },
                                      child: PodcastCard(podcast: e)),
                                )
                                .toList()),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    PodcastState state = context.watch<PodcastBloc>().state;
    // Define the empty state widget
    Widget emptyStateWidget = Padding(
      padding: const EdgeInsets.symmetric(vertical: _spacing * 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: _spacing,
        children: [
          const Text("You have no subscribed podcasts yet"),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: const Row(
              children: [
                Text("Search for podcasts with "),
                Icon(
                  Icons.search_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Helper function to build the grid
    Widget buildGrid(List<dynamic> podcasts) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Padding(
          padding: const EdgeInsets.all(_spacing),
          child: Container(
            decoration: buildBoxDecoration(context),
            child: Padding(
              padding: const EdgeInsets.all(_spacing * 0.5),
              child: GridView.builder(
                itemCount: podcasts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: _spacing * 0.5,
                  mainAxisSpacing: _spacing * 0.5,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return SubscribedPodcastCard(
                    podcast: podcasts[index],
                  );
                },
              ),
            ),
          ),
        ),
      );
    }

    Widget buildLoadingWidget() {
      return Builder(
          builder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Center(
                  ///TODO: Replace with app logo
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset("assets/placeholder.png"),
                  ),
                ),
              ));
    }

    // Build the grid based on the state
    return state.status == PodcastStatus.loading
        ? buildLoadingWidget()
        : state.subscribedPodcasts.isEmpty
            ? emptyStateWidget
            : buildGrid(state.subscribedPodcasts);
  }
}
