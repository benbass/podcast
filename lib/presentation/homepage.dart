import 'package:flutter/material.dart';
import 'package:podcast/presentation/page_transition.dart';
import 'package:podcast/presentation/podcast_search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List fakeEmptyList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Podcast app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            fakeEmptyList.isEmpty
                ? const Column(
                  children: [
                    Text("Quite empty here!"),
                    Text("Search and follow podcasts."),
                    Icon(Icons.arrow_downward_rounded, size: 50,),
                    SizedBox(height: 100,),
                  ],
                )
                : const SizedBox.shrink(),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  SlideRightRoute(
                    page: const PodcastSearchPage(),
                  ),
                );
              },
              child: const Text(
                'Search podcast',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
