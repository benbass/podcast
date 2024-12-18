import 'dart:io';

import 'package:flutter/material.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/page_transition.dart';

import '../helpers/core/get_android_version.dart';
import 'package:podcast/presentation/podcast_details_page.dart';

class PodcastSearchResultsPage extends StatefulWidget {
  final List<PodcastEntity> results;
  final String title;
  const PodcastSearchResultsPage({super.key, required this.results, required this.title});

  @override
  PodcastSearchResultsPageState createState() => PodcastSearchResultsPageState();
}

class PodcastSearchResultsPageState extends State<PodcastSearchResultsPage> {
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
                      return Card(
                        key: ValueKey(entry.id),
                        color: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5.0,
                        shadowColor: Colors.black,
                        margin: const EdgeInsets.all(8.0),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          height: 90.0,
                          child: InkWell(
                            splashColor: Colors.black87,
                            onTap: () {
                              Navigator.push(
                                context,
                                ScaleRoute(
                                  page: PodcastDetailsPage(
                                    podcast: entry,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: FadeInImage(
                                    fadeOutDuration:
                                        const Duration(milliseconds: 100),
                                    fadeInDuration:
                                        const Duration(milliseconds: 200),
                                    imageErrorBuilder:
                                        (context, error, stackTrace) {
                                      return Image.asset(
                                        "assets/placeholder.png",
                                        fit: BoxFit.cover,
                                        height: 90,
                                      );
                                    },
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.cover,
                                    placeholder: const AssetImage(
                                        'assets/placeholder.png'),
                                    image: Image.network(
                                      imgSrc,
                                    ).image,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      6.0,
                                      10.0,
                                      8.0,
                                      10.0,
                                    ),
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
