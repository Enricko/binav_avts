part of 'user_bloc.dart';

@immutable
sealed class UserEvent {}

final class SignIn extends UserEvent{
  final String email;
  final String password;

  SignIn({required this.email,required this.password});

  @override
  List<Object> get props =>[email,password];
}

final class SignOut extends UserEvent{}
final class CheckSignInStatus extends UserEvent{}