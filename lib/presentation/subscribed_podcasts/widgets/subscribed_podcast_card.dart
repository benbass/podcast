import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcast/presentation/custom_widgets/elevated_button_subscribe.dart';
import 'package:podcast/presentation/subscribed_podcasts/widgets/rounded_text_widget.dart';

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
    ImageProvider img = MyImageProvider(url: podcast.artwork).imageProvider;
    return InkResponse(
      onTap: () {
        podcastBloc.add(PodcastTappedEvent(podcast: podcast));
        Navigator.push(
          context,
          SlideBottomRoute(
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
            image: DecorationImage(image: img, fit: BoxFit.fitHeight),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ElevatedButtonSubscribe(
                podcast: podcast,
                navigate: false,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Spacer(),
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: RoundedTextWidget(
                        text: podcast.unreadEpisodes.toString()),
                    /*CustomPaint(
                      painter: TrianglePainter(
                        text: '410',
                      ),
                    ),*/
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
