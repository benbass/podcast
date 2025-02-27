import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:podcast/helpers/core/image_provider.dart';
import '../../../application/podcast_bloc/podcast_bloc.dart';
import '../../../domain/entities/podcast_entity.dart';
import '../../custom_widgets/page_transition.dart';
import '../../podcast_details_page/podcast_details_page.dart';

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
        return Card(
          key: ValueKey(podcast.pId),
          color: Theme.of(context).colorScheme.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
              color: podcast.subscribed ? Colors.grey : Colors.transparent,
              width: 3.0,
            ),
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
                BlocProvider.of<PodcastBloc>(context)
                    .add(PodcastTappedEvent(podcast: podcast));
                Navigator.push(
                  context,
                  SizeRoute(
                    page: const PodcastDetailsPage(),
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
                          image: imageProvider,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6.0, 10.0, 8.0, 10.0),
                      child: Text(
                        podcast.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
