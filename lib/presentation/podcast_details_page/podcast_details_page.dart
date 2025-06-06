import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:podcast/presentation/podcast_details_page/widgets/podcast_category.dart';
import 'package:podcast/presentation/podcast_details_page/widgets/row_icon_buttons_podcasts.dart';
import '../../application/podcast_bloc/podcast_bloc.dart';
import '../custom_widgets/decoration/box_decoration.dart';
import '../custom_widgets/dialogs/failure_dialog.dart';
import '../custom_widgets/flexible_space.dart';

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
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            FlexibleSpace(
              podcast: state.currentPodcast,
              episode: null,
              title: state.currentPodcast.title,
            ),
            SliverPadding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 10.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...state.currentPodcast.categories
                          .map((value) => PodcastCategory(
                                value: value,
                              )),
                    ],
                  ),
                )),
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: SliverToBoxAdapter(
                child: Container(
                    decoration: buildBoxDecoration(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          RowIconButtonsPodcasts(podcast: state.currentPodcast),
                    )),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 100.0),
              sliver: SliverToBoxAdapter(
                child: Container(
                  decoration: buildBoxDecoration(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.language,
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
      ),
    );
  }
}
