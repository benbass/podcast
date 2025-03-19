import 'package:flutter/material.dart';

import 'package:podcast/helpers/core/image_provider.dart';
import '../../../domain/entities/podcast_entity.dart';

class PodcastCard extends StatelessWidget {
  const PodcastCard({
    super.key,
    required this.podcast,
  });

  final PodcastEntity podcast;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageProvider>(
      future: MyImageProvider(url: podcast.artwork).imageProvider,
      builder: (BuildContext context, AsyncSnapshot<ImageProvider> snapshot) {
        final ImageProvider imageProvider = snapshot.hasData
            ? snapshot.data!
            : const AssetImage('assets/placeholder.png');
        return Container(
          key: ValueKey(podcast.pId),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: podcast.subscribed
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.transparent,
              width: 3.0,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.fitWidth,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              imageProvider == const AssetImage('assets/placeholder.png')
                  ? Center(
                      child: Text(
                        podcast.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white, // Adjust text color as needed
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        );
      },
    );
  }
}
