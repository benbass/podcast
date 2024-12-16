import 'package:bloc/bloc.dart';

class CurrentUrlCubit extends Cubit<String> {
  CurrentUrlCubit() : super("");

  void setCurrentEpisodeUrl(String url){
    emit(url);
  }
}
