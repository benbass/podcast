import 'package:flutter/material.dart';
import 'package:podcast/presentation/homepage/widgets/rounded_text_widget.dart';

import '../../../domain/entities/subscribed_podcast_entity.dart';

class SubscribedPodcastCard extends StatelessWidget {
  final SubscribedPodcastEntity subscribedPodcast;
  const SubscribedPodcastCard({
    super.key,
    required this.subscribedPodcast,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () {},
      child: Material(
        elevation: 16,
        borderRadius: BorderRadius.circular(15),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: MemoryImage(subscribedPodcast.artwork!),
                fit: BoxFit.fitHeight),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Spacer(),
              SizedBox(
                width: 50,
                height: 50,
                child: RoundedTextWidget(text: "34"),
                /*CustomPaint(
                  painter: TrianglePainter(
                    text: '410',
                  ),
                ),*/
              ),
            ],
          ),
        ),
      ),
    );
  }
}
