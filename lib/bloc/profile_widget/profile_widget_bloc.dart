import 'package:binav_avts/services/user_dataservice.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:meta/meta.dart';

part 'profile_widget_event.dart';
part 'profile_widget_state.dart';

class ProfileWidgetBloc extends Bloc<ProfileWidgetEvent, ProfileWidgetState> {
  ProfileWidgetBloc() : super(AuthProfile()) {
    on<Profile>((event, emit) {
      emit(AuthProfile());
    });
    on<ChangePassword>((event, emit) {
      emit(AuthChangePassword());
    });
    on<LogOut>((event, emit) async {
        emit(AuthLogOut());
    });
  }
}
