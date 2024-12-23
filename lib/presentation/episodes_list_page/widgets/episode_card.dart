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
    ImageProvider img = MyImageProvider(url: item.image).imageProvider;
    return Card(
      key: ValueKey(item.pId),
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
            ],
          ),
        ),
      ),
    );
  }
}
