import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/domain/usecases/episode_usecases.dart';
import 'package:podcast/injection.dart';
import 'package:podcast/presentation/subscribed_podcasts_homepage/widgets/rounded_text_widget.dart';
import '../../../application/podcast_bloc/podcast_bloc.dart';
import '../../../domain/entities/podcast_entity.dart';
import '../../../helpers/core/image_provider.dart';
import '../../custom_widgets/page_transition.dart';
import '../../episodes_list_page/episodes_list_page.dart';

class SubscribedPodcastCard extends StatelessWidget {
  final PodcastEntity podcast;
  const SubscribedPodcastCard({
    super.key,
    required this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    final podcastBloc = BlocProvider.of<PodcastBloc>(context);
    return FutureBuilder<ImageProvider>(
        future: MyImageProvider(url: podcast.artwork).imageProvider,
        builder: (BuildContext context, AsyncSnapshot<ImageProvider> snapshot) {
          final ImageProvider imageProvider = snapshot.hasData
              ? snapshot.data!
              : const AssetImage('assets/placeholder.png');
          return InkResponse(
            onTap: () {
              podcastBloc.add(PodcastTappedEvent(podcast: podcast));
              Navigator.push(
                context,
                ScaleRoute(
                  page: const EpisodesListPage(),
                ),
              );
            },
            child: Material(
              elevation: 16,
              borderRadius: BorderRadius.circular(15),
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.fitHeight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: SizedBox(
                          width: 50,
                          height: 50,
                          child: StreamBuilder<int>(
                            stream: getIt<EpisodeUseCases>().unreadLocalEpisodesCount(feedId: podcast.pId),
                            builder: (context, snapshot) {
                              return RoundedTextWidget(
                                text: snapshot.data.toString()
                              );
                            }
                          )),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
