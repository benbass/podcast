import 'package:flutter/material.dart';
import 'package:podcast/helpers/core/image_provider.dart';
import 'package:podcast/presentation/custom_widgets/elevated_button_subscribe.dart';

import '../../../domain/entities/podcast_entity.dart';
import '../../custom_widgets/page_transition.dart';
import '../../podcast_details_page/podcast_details_page.dart';

class PodcastCard extends StatelessWidget {
  const PodcastCard({
    super.key,
    required this.entry,
    required this.imgSrc,
    required this.title,
  });

  final PodcastEntity entry;
  final String imgSrc;
  final String title;

  @override
  Widget build(BuildContext context) {
    ImageProvider img = MyImageProvider(url: imgSrc).imageProvider;
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
                child: Container(
                  width: 90,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: img,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.zero,
                        height: 30,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButtonSubscribe(),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
