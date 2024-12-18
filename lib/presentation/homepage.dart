import 'package:flutter/material.dart';
import 'package:podcast/presentation/page_transition.dart';
import 'package:podcast/presentation/podcast_search_results_page.dart';

import '../domain/entities/podcast_entity.dart';
import '../domain/repositories/podcast_query_repository.dart';
import '../helpers/core/get_android_version.dart';
import '../injection.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // Map to store the extracted values
  List<PodcastEntity> results = [];

  String title = "Podcasts";
  String hintText = "Search";

  final TextEditingController _textEditingController = TextEditingController();

  bool isLoading = false;

  List fakeEmptyList = [];

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
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: hintText,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () async {
                              FocusScope.of(context).unfocus();

                              //Setting isLoading true to show the loader
                              setState(() {
                                isLoading = true;
                              });

                              //Awaiting for web scraping function to return list of strings
                              final response =
                                  await sl<PodcastQueryRepository>()
                                      .getPodcastsOnQuery(
                                          _textEditingController.text);
                              final String keyword = _textEditingController.text;
                              _textEditingController.clear();

                              //Setting the received strings to be displayed and making isLoading false to hide the loader
                              setState(() {
                                results = response;
                                isLoading = false;
                                title = "${results.length} podcasts";
                                if(results.isEmpty){
                                  hintText = "No podcast was found";
                                }
                              });
                              if (results.isNotEmpty) {
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    SlideRightRoute(
                                      page: PodcastSearchResultsPage(
                                        results: results,
                                        title:
                                            '$title for "$keyword"',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF202531),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            fakeEmptyList.isEmpty
                ? const SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 50,
                        ),
                        Text("Quite empty here!"),
                        Text("Search and follow podcasts."),
                      ],
                    ),
                  )
                : const SliverToBoxAdapter(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
