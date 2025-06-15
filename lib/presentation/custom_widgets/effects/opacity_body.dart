import 'dart:io';

import 'package:flutter/material.dart';

import '../../../application/podcast_bloc/podcast_bloc.dart';

class OpacityBody extends StatelessWidget {
  const OpacityBody({
    super.key,
    required this.state,
    required this.assetImage,
  });

  final PodcastState? state;
  final AssetImage? assetImage;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.4,
      child: state != null ? Image.file(
        File(state!.currentPodcast.artworkFilePath!),
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error,
            StackTrace? stackTrace) {
          return const SizedBox();
        },
      ) : Image.asset(
        'assets/placeholder.png',
        fit: BoxFit.cover,
      ),
    );
  }
}