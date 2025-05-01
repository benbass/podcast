import 'package:bloc/bloc.dart';
import 'package:podcast/domain/entities/episode_entity.dart';

import '../../domain/entities/podcast_entity.dart';

class EpisodePlaybackCubit extends Cubit<Map<PodcastEntity, EpisodeEntity>?> {
  EpisodePlaybackCubit() : super(null);

  void setPlaybackEpisode(Map<PodcastEntity, EpisodeEntity>? episodePlayback){
   emit(episodePlayback);
  }
}
