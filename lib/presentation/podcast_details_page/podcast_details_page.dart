import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/presentation/podcast_details_page/widgets/drawer.dart';

import 'package:podcast/presentation/podcast_details_page/widgets/podcast_category.dart';
import 'package:podcast/presentation/podcast_details_page/widgets/row_icon_buttons_podcasts.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../../application/podcast_settings_cubit/podcast_settings_cubit.dart';
import '../../domain/entities/podcast_entity.dart';
import '../custom_widgets/decoration/box_decoration.dart';
import '../custom_widgets/dialogs/failure_dialog.dart';
import '../custom_widgets/effects/backdropfilter.dart';
import '../custom_widgets/effects/opacity_body.dart';
import '../custom_widgets/elevated_button_subscribe.dart';
import '../custom_widgets/page_transition.dart';
import '../episodes_list_page/episodes_list_page.dart';

class PodcastDetailsPage extends StatelessWidget {
  const PodcastDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeDate = Theme.of(context);
    return BlocBuilder<PodcastBloc, PodcastState>(
      builder: (context, state) {
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
        else if (state.status == PodcastStatus.loading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (state.status == PodcastStatus.success) {
          BlocProvider.of<PodcastSettingsCubit>(context).loadSettings(state.currentPodcast.id);
        }
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: _buildBackButton(context),
            actions: [
              RowIconButtonsPodcasts(podcast: state.currentPodcast),
            ],
            actionsPadding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          drawer: SafeArea(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                  child: Drawer(
                    backgroundColor: Colors.white12,
                    surfaceTintColor: themeDate.colorScheme.secondary,
                    width: MediaQuery.of(context).size.width * 0.85,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: const PodcastSettingsDrawer(),
                  ),
                ),
              ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (state.currentPodcast.artworkFilePath != null)
                OpacityBody(
                  state: state,
                ),
              const BackdropFilterWidget(sigma: 25.0,),
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    primary: false,
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    pinned: false,
                    expandedHeight: MediaQuery.of(context).size.height * 0.33,
                    collapsedHeight: MediaQuery.of(context).size.height * 0.15,
                    floating: true,
                    snap: true,
                    stretch: true,
                    flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        collapseMode: CollapseMode.parallax,
                        background: _buildBackgroundImage(
                          _getImageUrl(state.currentPodcast),
                          state.currentPodcast,
                        ),
                        expandedTitleScale: 1,
                        title: ElevatedButtonSubscribe(
                          podcast: state.currentPodcast,
                        )),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 170),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        decoration: buildBoxDecoration(context),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Text(
                                  state.currentPodcast.title,
                                  style: themeDate.textTheme.displayLarge,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  List<Widget> categoryColumns = [];
                                  List<String> categories =
                                      state.currentPodcast.categories;
                                  int maxItemsPerColumn = 3;

                                  for (int i = 0;
                                  i < categories.length;
                                  i += maxItemsPerColumn) {
                                    List<Widget> currentColumnItems = [];
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
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                state.currentPodcast.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                state.currentPodcast.author,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 20.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.language,
                                      color: themeDate.colorScheme.primary,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      state.currentPodcast.language.toUpperCase(),
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
            ],
          ),
        );
      },
    );
  }

  /// Determines the image URL based on whether an episode or podcast is provided.
  String _getImageUrl(PodcastEntity podcast) {
    return podcast.artworkFilePath ?? podcast.artwork;
  }

  /// Builds the background image..
  Widget _buildBackgroundImage(
    String imageUrl,
    PodcastEntity podcast,
  ) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: podcast.artworkFilePath != null
                ? FileImage(File(podcast.artworkFilePath!))
                : const AssetImage('assets/placeholder.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
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
