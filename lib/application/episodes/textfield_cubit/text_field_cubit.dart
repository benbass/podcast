import 'package:bloc/bloc.dart';

class TextFieldCubit extends Cubit<String?> {
  TextFieldCubit() : super(null);

  void setKeyword(String? keyword){
    emit(keyword);
  }
}
