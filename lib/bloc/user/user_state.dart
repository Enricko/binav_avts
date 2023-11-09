part of 'user_bloc.dart';

@immutable
sealed class UserState {}

final class UserSignedOut extends UserState {
  final String message;
  final TypeMessageAuth? type;
  UserSignedOut({this.message = "",this.type});

  List<Object> get props => [message];

}
final class UserSignedIn extends UserState {
  final UserResponse user;

  UserSignedIn({required this.user});

  List<Object> get props => [user];
}