import 'package:bloc/bloc.dart';

class EpisodePlaybackUrlCubit extends Cubit<String> {
  EpisodePlaybackUrlCubit() : super("");

  void setPlaybackEpisodeUrl(String url){
    emit(url);
  }
}
