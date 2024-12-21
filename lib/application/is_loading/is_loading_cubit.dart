import 'package:bloc/bloc.dart';

class IsLoadingCubit extends Cubit<bool> {
  IsLoadingCubit() : super(false);

  void setIsLoading(bool isLoading){
    emit(isLoading);
  }
}
