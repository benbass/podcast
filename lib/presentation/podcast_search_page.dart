import 'dart:io';

import 'package:flutter/material.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/page_transition.dart';

import '../domain/repositories/podcast_query_repository.dart';
import '../helpers/core/get_android_version.dart';
import '../injection.dart';
import 'package:podcast/presentation/podcast_details_page.dart';

class PodcastSearchPage extends StatefulWidget {
  const PodcastSearchPage({super.key});

  @override
  PodcastSearchPageState createState() => PodcastSearchPageState();
}

class PodcastSearchPageState extends State<PodcastSearchPage> {
  String title = "Podcasts";
// Map to store the extracted values
  List<PodcastEntity> results = [];

  final TextEditingController _textEditingController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    getAndroidVersion();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.home_rounded),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                  child: Column(
                    children: [
                      TextField(
                        controller: _textEditingController,
                        onTapOutside: (_) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: const TextStyle(
                          color: Color(0xFF202531),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();

                          //Setting isLoading true to show the loader
                          setState(() {
                            isLoading = true;
                          });

                          //Awaiting for web scraping function to return list of strings
                          final response = await sl<PodcastQueryRepository>()
                              .getPodcastsOnQuery(_textEditingController.text);

                          //Setting the received strings to be displayed and making isLoading false to hide the loader
                          setState(() {
                            results = response;
                            isLoading = false;
                            title = "${results.length} podcasts";
                          });
                        },
                        child: const Text(
                          'Search',
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            isLoading
                ? SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                : SliverList.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final entry = results.elementAt(index);
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
