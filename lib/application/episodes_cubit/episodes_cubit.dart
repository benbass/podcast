import 'package:bloc/bloc.dart';

import '../../domain/entities/episode_entity.dart';

class EpisodesCubit extends Cubit<List<EpisodeEntity>> {
  EpisodesCubit() : super([]);

  void setEpisodes(List<EpisodeEntity> episodes){
    emit(episodes);
  }
}
