import 'package:bloc/bloc.dart';

class ShowFlaggedListCubit extends Cubit<String?> {
  ShowFlaggedListCubit() : super(null);

  void setFlag(String? onlyFlagged){
    emit(onlyFlagged);
  }
}
