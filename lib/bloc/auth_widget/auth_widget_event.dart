part of 'auth_widget_bloc.dart';

@immutable
sealed class AuthWidgetEvent {}

final class Login extends AuthWidgetEvent{
  // List<Object> get props => [];
}

final class EmailConfirm extends AuthWidgetEvent{}
final class OtpConfirm extends AuthWidgetEvent{
  final String email;

  OtpConfirm({required this.email});

  List<Object> get props => [email];
}
final class ResetPassword extends AuthWidgetEvent{
  final String code;
  final String email;

  ResetPassword({required this.code,required this.email});

  List<Object> get props => [code,email];
}

final class ResetSuccess extends AuthWidgetEvent{
  final String code;
  final String password;
  final String password_confirmation;

  ResetSuccess({required this.code,required this.password,required this.password_confirmation});

  List<Object> get props => [code,password,password_confirmation];
}