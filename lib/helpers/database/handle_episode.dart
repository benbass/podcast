import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/episodes_cubit/episodes_cubit.dart';
import '../../core/globals.dart';
import '../../domain/entities/episode_entity.dart';

void updateEpisodeOnFlagChanged(BuildContext context, EpisodeEntity episode) {
  // Get the latest episode version from db since we just changed a flag value
  final episodeDb = episodeBox.get(episode.id)!;
  // We delete episode from db if it doesn't belong to any subscribed podcasts and all flag values are reset to initial
  if ((episodeDb.isSubscribed == false) &
  (episodeDb.favorite == false) &
  (episodeDb.filePath == null) &
  (episodeDb.position == 0)) {
    episodeBox.remove(episodeDb.id);
  }
  if((episodeDb.isSubscribed == false) &
  (episodeDb.favorite == true) ||
      (episodeDb.filePath != null) ||
      (episodeDb.position != 0)){
    final episodes = BlocProvider.of<EpisodesCubit>(context).state;
    if (episodes.isNotEmpty) {
      int index = episodes.indexWhere((element) => element.eId == episodeDb.eId);
      episodes.insert(index, episodeDb);
      episodes.removeAt(index+1);
      BlocProvider.of<EpisodesCubit>(context).setEpisodes(episodes);
    }
  }
}