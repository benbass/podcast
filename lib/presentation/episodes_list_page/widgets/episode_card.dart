import 'package:flutter/material.dart';

import '../../../domain/entities/episode_entity.dart';
import '../../../helpers/core/format_pubdate_string.dart';
import '../../custom_widgets/page_transition.dart';
import '../../episode_selected_page/episode_selected_page.dart';
import '../episodes_list_page.dart';

class EpisodeCard extends StatelessWidget {
  const EpisodeCard({
    super.key,
    required this.item,
    required this.widget,
  });

  final EpisodeEntity item;
  final PodcastEpisodesPage widget;

  @override
  Widget build(BuildContext context) {
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
            EpisodeEntity episode = EpisodeEntity(
              pId: item.pId,
              title: item.title,
              description: item.description,
              guid: item.guid,
              datePublished: item.datePublished,
              datePublishedPretty: item.datePublishedPretty,
              enclosureUrl: item.enclosureUrl,
              enclosureLength: item.enclosureLength,
              duration: item.duration,
              explicit: item.explicit,
              episodeNr: item.episodeNr,
              episodeType: item.episodeType,
              season: item.season,
              image: item.image,
              feedUrl: item.feedUrl,
              link: item.link,
              feedImage: item.feedImage,
              feedId: item.feedId,
              podcastGuid: item.podcastGuid,
              favorite: item.favorite,
              read: item.read,
              completed: item.completed,
              position: item.position,
            );
            Navigator.push(
              context,
              ScaleRoute(
                page: EpisodeSelectedPage(
                  episode: episode,
                  podcast: widget.podcast,
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
                  fadeOutDuration: const Duration(milliseconds: 100),
                  fadeInDuration: const Duration(milliseconds: 200),
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/placeholder.png",
                      fit: BoxFit.cover,
                      height: 90.0,
                    );
                  },
                  height: 90.0,
                  width: 90.0,
                  fit: BoxFit.cover,
                  placeholder: const AssetImage('assets/placeholder.png'),
                  image: Image.network(
                    item.image,
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
