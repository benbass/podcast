import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:podcast/presentation/page_transition.dart';

import '../domain/entities/podcast_entity.dart';
import 'package:podcast/presentation/podcast_episodes_page.dart';

class PodcastDetailsPage extends StatelessWidget {
  final PodcastEntity podcast;

  const PodcastDetailsPage({
    super.key,
    required this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Podcast: ${podcast.title}"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 3,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: podcast.artwork != ''
                    ? NetworkImage(podcast.artwork)
                    : const AssetImage("assets/placeholder.png"),
                fit: BoxFit.fitWidth,
              ),
            ),
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Center(
                  child: FadeInImage(
                    fadeOutDuration: const Duration(milliseconds: 100),
                    fadeInDuration: const Duration(milliseconds: 200),
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/placeholder.png",
                        fit: BoxFit.cover,
                        //height: 300,
                        //width: 300,
                      );
                    },
                    //height: 300,
                    //width: 300,
                    fit: BoxFit.cover,
                    placeholder: const AssetImage('assets/placeholder.png'),
                    image: NetworkImage(podcast.artwork),
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 4,
                  child: SingleChildScrollView(
                    child: Text(
                      podcast.description,
                      style: const TextStyle(fontSize: 15,),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    SlideRightRoute(
                      page: PodcastEpisodesPage(
                        podcast: podcast,
                      ),
                    ),
                  );
                },
                child: const Text('Episodes'),
              ),
              TextButton(
                onPressed: () {
                  // save podcast to db
                },
                child: const Text('Follow'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
