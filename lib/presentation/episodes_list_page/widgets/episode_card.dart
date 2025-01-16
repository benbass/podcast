import 'package:flutter/material.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';

import '../../../domain/entities/episode_entity.dart';
import '../../../helpers/core/format_pubdate_string.dart';
import '../../../helpers/core/image_provider.dart';
import '../../custom_widgets/page_transition.dart';
import '../../episode_selected_page/episode_selected_page.dart';

class EpisodeCard extends StatelessWidget {
  const EpisodeCard({
    super.key,
    required this.item,
    required this.podcast,
  });

  final EpisodeEntity item;
  final PodcastEntity podcast;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);;
    ImageProvider img = MyImageProvider(url: item.image).imageProvider;
    return Card(
      key: ValueKey(item.pId),
      color: themeData.colorScheme.secondary,
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
          onTap: () async {
            Navigator.push(
              context,
              ScaleRoute(
                page: EpisodeSelectedPage(
                  episode: item,
                  podcast: podcast,
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
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: img,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    if(item.position > 0)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: SizedBox(
                        height: 90,
                        width: 90,
                        child: LinearProgressIndicator(
                          value: (item.position.toDouble()/item.duration!.toDouble()).clamp(0.0, 1.0),
                          color: themeData.colorScheme.primary.withValues(alpha: 0.6),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    )
                  ],
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 2,
                      ),
                      Text(
                        formatTimestamp(
                          item.datePublished,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
               Padding(
                 padding: const EdgeInsets.only(right: 8.0),
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(item.read ? Icons.check_rounded : null),
                    Icon(item.favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                  ],
                               ),
               )
            ],
          ),
        ),
      ),
    );
  }
}
