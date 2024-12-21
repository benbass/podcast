import 'dart:io';

import 'package:flutter/material.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/podcast_results_page/widgets/podcast_card.dart';

import '../../helpers/core/get_android_version.dart';

class PodcastResultsPage extends StatefulWidget {
  final List<PodcastEntity> results;
  final String title;
  const PodcastResultsPage(
      {super.key, required this.results, required this.title});

  @override
  PodcastResultsPageState createState() => PodcastResultsPageState();
}

class PodcastResultsPageState extends State<PodcastResultsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.home_rounded),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverList.builder(
              itemCount: widget.results.length,
              itemBuilder: (context, index) {
                final entry = widget.results.elementAt(index);
                final title = entry.title;
                final imgSrc = entry.artwork;
                return PodcastCard(
                  entry: entry,
                  imgSrc: imgSrc,
                  title: title,
                );
              },
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 80,
              ),
            ),
          ],
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
