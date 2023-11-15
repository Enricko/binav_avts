part of 'auth_widget_bloc.dart';

@immutable
sealed class AuthWidgetState {}

final class AuthLogin extends AuthWidgetState {}

final class AuthEmailConfirm extends AuthWidgetState {}

final class AuthOtpConfirm extends AuthWidgetState {
  final String email;

  AuthOtpConfirm({required this.email});

  List<Object> get props => [email];
}
final class AuthResetPassword extends AuthWidgetState {
  final String code;
  final String email;

  AuthResetPassword({required this.code,required this.email});

  List<Object> get props => [code,email];
}

final class AuthResetSuccess extends AuthWidgetState {}
