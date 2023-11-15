import 'package:binav_avts/services/user_dataservice.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:meta/meta.dart';

part 'auth_widget_event.dart';
part 'auth_widget_state.dart';

class AuthWidgetBloc extends Bloc<AuthWidgetEvent, AuthWidgetState> {
  AuthWidgetBloc() : super(AuthLogin()) {
    on<Login>((event, emit) {
      emit(AuthLogin());
    });
    on<EmailConfirm>((event, emit) {
      emit(AuthEmailConfirm());
    });
    on<OtpConfirm>((event, emit) async {
      EasyLoading.show(status: "Loading...");
      var data = await UserDataService().forgotPassword(email: event.email);
      if (data.message == "We have emailed your password reset link.") {
        emit(AuthOtpConfirm(email: event.email));
        EasyLoading.dismiss();
      } else {
        EasyLoading.showError("Email is invalid try another email",
            duration: const Duration(seconds: 3), dismissOnTap: true);
      }
    });
    on<ResetPassword>((event, emit) async {
      if (state is AuthOtpConfirm) {
        EasyLoading.show(status: "Loading...");
        var data = await UserDataService().checkOtp(code: event.code);

        if (data.message == "Code OTP is Valid") {
          emit(AuthResetPassword(code: event.code, email: event.email));
          EasyLoading.dismiss();
        } else {
          EasyLoading.showError("Code OTP is invalid", duration: const Duration(seconds: 3), dismissOnTap: true);
        }
      }
    });
    on<ResetSuccess>((event, emit) async {
      if (state is AuthResetPassword) {
        EasyLoading.show(status: "Loading...");
        var dataMap = {
          "code": event.code,
          "password": event.password,
          "password_confirmation": event.password_confirmation
        };
        var data = await UserDataService().resetPassword(data: dataMap);

        if (data.message == "password has been successfully reset") {
          emit(AuthResetSuccess());
          EasyLoading.dismiss();
        } else {
          EasyLoading.showError(data.message!, duration: const Duration(seconds: 3), dismissOnTap: true);
        }
      }
    });
  }
}
