import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/application/podcasts_bloc/podcasts_bloc.dart';
import 'package:podcast/presentation/podcast_results_page/widgets/podcast_card.dart';

import '../../helpers/core/get_android_version.dart';

class PodcastResultsPage extends StatelessWidget {
  const PodcastResultsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<PodcastsBloc, PodcastsState>(
          builder: (context, state) {
            if (state is PodcastsReceivedState) {
              return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Podcasts for: ${state.keyword}",
                  ));
            } else {
              return const Text("");
            }
          },
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.home_rounded),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<PodcastsBloc, PodcastsState>(
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                if (state is PodcastsReceivedState)
                  if (state.podcasts.isNotEmpty)
                    SliverList.builder(
                      itemCount: state.podcasts.length,
                      itemBuilder: (context, index) {
                        final entry = state.podcasts.elementAt(index);
                        final title = entry.title;
                        final imgSrc = entry.artwork;
                        return PodcastCard(
                          entry: entry,
                          imgSrc: imgSrc,
                          title: title,
                        );
                      },
                    )
                  else
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          children: [
                            const Spacer(),
                            const Text(
                                "No podcasts were found for your keyword(s)"),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 36,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 80,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      // following bar just to hide listtiles to appear under system bottombar on Android15+ (because of edge to edge)
      bottomNavigationBar: Platform.isAndroid && androidVersion > 14
          ? Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              height: MediaQuery.of(context).padding.bottom,
            )
          : null,
    );
  }
}
