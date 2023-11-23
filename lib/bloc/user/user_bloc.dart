import 'package:binav_avts/bloc/utils/utils_bloc.dart';
import 'dart:async';

import 'package:binav_avts/services/user_dataservice.dart';
import 'package:binav_avts/response/user_response.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserDataService userDataSource;
  UserBloc({required this.userDataSource}) : super(UserSignedOut()) {
    on<SignIn>((event, emit) async {
      if (state is UserSignedOut) {
        final getUser = await userDataSource.login(email: event.email, password: event.password);
        if (state == CheckboxState.checked) {
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setString('rememberMe', getUser.user!.email!);
        }
        if (getUser.message!.contains("Login Success")) {
          SharedPreferences pref = await SharedPreferences.getInstance();
          if (getUser.client!.idClient != null) {
            pref.setString('idClient', getUser.client!.idClient!);
          }
          pref.setString('idUser', getUser.user!.idUser!);
          pref.setString('email', event.email);
          pref.setString('level', getUser.user!.level!);
          pref.setString('token', getUser.token!);

          emit(UserSignedIn(user: getUser));
          await EasyLoading.dismiss();
        } else {
          EasyLoading.showError(getUser.message!, duration: const Duration(milliseconds: 3000), dismissOnTap: true);
          emit(UserSignedOut(message: getUser.message!, type: TypeMessageAuth.Error));
        }
      }
    });
    on<SignOut>((event, emit) async {
      EasyLoading.show(status: "Loading...");
      SharedPreferences pref = await SharedPreferences.getInstance();
      final getUser = await userDataSource.logout(token: pref.getString("token").toString());
      pref.remove('idClient');
      pref.remove('idUser');
      pref.remove('email');
      pref.remove('level');
      pref.remove('token');
      if (getUser.message != null) {
        EasyLoading.showSuccess(getUser.message!,
              duration: const Duration(milliseconds: 3000), dismissOnTap: true);
        emit(UserSignedOut(message: getUser.message!, type: TypeMessageAuth.Logout));
      } else {
        emit(UserSignedOut());
          await EasyLoading.dismiss();
      }
    });
    on<CheckSignInStatus>((event, emit) async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? email = pref.getString("email");
      String? token = pref.getString("token");

      if (email != null && token != null) {
        final getUser = await userDataSource.getUser(token: token);

        if (getUser.token != null) {
          emit(UserSignedIn(user: getUser));
        } else {
          add(SignOut());
          EasyLoading.showSuccess("Authentication session are over!!",
              duration: const Duration(milliseconds: 3000), dismissOnTap: true);
          emit(UserSignedOut());
        }
      } else {
        emit(UserSignedOut());
      }
    });
  }
}
