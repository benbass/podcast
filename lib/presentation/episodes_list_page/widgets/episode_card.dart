import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/application/episode_playback/episode_playback_cubit.dart';
import 'package:podcast/domain/entities/podcast_entity.dart';

import '../../../domain/entities/episode_entity.dart';
import '../../../helpers/core/format_pubdate_string.dart';
import '../../../helpers/core/image_provider.dart';
import '../../custom_widgets/page_transition.dart';
import '../../episode_details_page/episode_details_page.dart';

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
    var themeData = Theme.of(context);
    return FutureBuilder<ImageProvider>(
        future: MyImageProvider(url: item.image).imageProvider,
        builder: (BuildContext context, AsyncSnapshot<ImageProvider> snapshot) {
          final ImageProvider imageProvider = snapshot.hasData
              ? snapshot.data!
              : const AssetImage('assets/placeholder.png');
          return BlocBuilder<EpisodePlaybackCubit, EpisodeEntity?>(
            builder: (context, state) {
              return Card(
                key: ValueKey(item.eId),
                color: themeData.colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: state?.eId == item.eId
                        ? BorderSide(
                            color: themeData.colorScheme.secondary,
                            width: 2.0,
                          )
                        : BorderSide.none),
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
                          page: EpisodeDetailsPage(
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
                                    image: imageProvider,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                              if (item.position > 0)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: SizedBox(
                                    height: 90,
                                    width: 90,
                                    child: LinearProgressIndicator(
                                      value: (item.position.toDouble() /
                                              item.duration!.toDouble())
                                          .clamp(0.0, 1.0),
                                      color: themeData.colorScheme.primary
                                          .withValues(alpha: 0.6),
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
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                ),
                                Text(
                                  formatTimestamp(
                                    item.datePublished,
                                  ),
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
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
                              Icon(item.favorite && podcast.subscribed
                                  ? Icons.favorite_rounded
                                  : null),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }
}
