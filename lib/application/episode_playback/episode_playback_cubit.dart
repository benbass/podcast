import 'package:bloc/bloc.dart';
import 'package:podcast/domain/entities/episode_entity.dart';

class EpisodePlaybackCubit extends Cubit<EpisodeEntity?> {
  EpisodePlaybackCubit() : super(null);

  void setPlaybackEpisode(EpisodeEntity? episode){
    emit(episode);
  }
}
