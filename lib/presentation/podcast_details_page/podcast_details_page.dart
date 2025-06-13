import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/presentation/podcast_details_page/widgets/drawer.dart';

import 'package:podcast/presentation/podcast_details_page/widgets/podcast_category.dart';
import 'package:podcast/presentation/podcast_details_page/widgets/row_icon_buttons_podcasts.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../../application/podcast_settings_cubit/podcast_settings_cubit.dart';
import '../../domain/entities/podcast_entity.dart';
import '../custom_widgets/decoration/box_decoration.dart';
import '../custom_widgets/dialogs/failure_dialog.dart';
import '../custom_widgets/elevated_button_subscribe.dart';
import '../custom_widgets/page_transition.dart';
import '../episodes_list_page/episodes_list_page.dart';
import '../episodes_list_page/widgets/animated_download_icon.dart';

class PodcastDetailsPage extends StatelessWidget {
  const PodcastDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PodcastBloc, PodcastState>(
      listener: (context, state) {
        if (state.status == PodcastStatus.failure &&
            !state.currentPodcast.subscribed) {
          showDialog(
            context: context,
            builder: (context) => const FailureDialog(
                message: "Error loading podcast details. Please try again."),
          ).whenComplete(() {
            if (context.mounted) {
              Navigator.pop(context);
            }
          });
        }
      },
      child: _buildPage(context),
    );
  }

  Scaffold _buildPage(BuildContext context) {
    PodcastState state = context.watch<PodcastBloc>().state;
    if (state.status == PodcastStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.status == PodcastStatus.success) {
      final int podcastId = state.currentPodcast.id;
      return Scaffold(
        drawer: BlocProvider(
          create: (context) => PodcastSettingsCubit()..loadSettings(podcastId),
          child: Builder(builder: (context) {
            return const Drawer(child: PodcastSettingsDrawer());
          }),
        ),
        body: Stack(
          children: [
            Stack(
              fit: StackFit.expand,
              children: [
                if (state.currentPodcast.artworkFilePath != null)
                  Opacity(
                    opacity: 0.4,
                    child: Image.file(
                      File(state.currentPodcast.artworkFilePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return const SizedBox();
                      },
                    ),
                  ),
                BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                  child: Container(
                    color: Colors.black26,
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.25),
                    child: CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          automaticallyImplyLeading: false,
                          backgroundColor: Colors.transparent,
                          expandedHeight:
                              MediaQuery.of(context).size.height * 0.18,
                          collapsedHeight: 90,
                          pinned: false,
                          floating: true,
                          title: Text(
                            state.currentPodcast.title,
                          ),
                          centerTitle: true,
                          titleTextStyle:
                              Theme.of(context).textTheme.displayLarge,
                          toolbarHeight: 20,
                          flexibleSpace: FlexibleSpaceBar(
                            title: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Wrap(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          List<Widget> categoryColumns = [];
                                          List<String> categories =
                                              state.currentPodcast.categories;
                                          int maxItemsPerColumn = 2;

                                          for (int i = 0;
                                              i < categories.length;
                                              i += maxItemsPerColumn) {
                                            List<Widget> currentColumnItems =
                                                [];
                                            for (int j = 0;
                                                j < maxItemsPerColumn &&
                                                    (i + j) < categories.length;
                                                j++) {
                                              currentColumnItems.add(
                                                PodcastCategory(
                                                  value: categories[i + j],
                                                ),
                                              );
                                            }
                                            categoryColumns.add(
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: currentColumnItems,
                                              ),
                                            );
                                          }

                                          return Wrap(
                                            spacing: 8.0,
                                            runSpacing: 0.0,
                                            children: categoryColumns,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Container(
                                        decoration: buildBoxDecoration(context),
                                        child: RowIconButtonsPodcasts(
                                            podcast: state.currentPodcast)),
                                  ),
                                ],
                              ),
                            ),
                            titlePadding: EdgeInsets.zero,
                          ),
                        ),
                        SliverPadding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 140),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              decoration: buildBoxDecoration(context),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.currentPodcast.description,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      state.currentPodcast.author,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20.0),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.language,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            state.currentPodcast.language
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.33,
              child: SafeArea(
                child: Container(
                  color: Colors.black12,
                  child: Stack(
                    children: [
                      _buildBackgroundImage(
                        _getImageUrl(state.currentPodcast),
                        state.currentPodcast,
                      ),
                      const Positioned(
                        top: 70,
                        left: 12,
                        child: AnimatedDownloadIcon(size: 42),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: ElevatedButtonSubscribe(
                          podcast: state.currentPodcast,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _buildBackButton(context),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const Scaffold(
          body: Center(child: Text("Error loading podcast details.")));
    }
  }

  /// Determines the image URL based on whether an episode or podcast is provided.
  String _getImageUrl(PodcastEntity podcast) {
    return podcast.artworkFilePath ?? podcast.artwork;
  }

  /// Builds the background image with blur effect.
  Widget _buildBackgroundImage(
    String imageUrl,
    PodcastEntity podcast,
  ) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.4,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: podcast.artworkFilePath != null
                    ? FileImage(File(podcast.artworkFilePath!))
                    : const AssetImage('assets/placeholder.png'),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ),
        ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: podcast.artworkFilePath != null
                        ? FileImage(File(podcast.artworkFilePath!))
                        : const AssetImage('assets/placeholder.png'),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
          ScaleRoute(
            page: const EpisodesListPageWrapper(),
          ),
          ModalRoute.withName('/'),
        );
      },
      icon: const BackButtonIcon(),
    );
  }
}
