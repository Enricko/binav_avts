part of 'profile_widget_bloc.dart';

@immutable
sealed class ProfileWidgetState {}

final class AuthProfile extends ProfileWidgetState {}

final class AuthChangePassword extends ProfileWidgetState {}

final class AuthLogOut extends ProfileWidgetState {
}
