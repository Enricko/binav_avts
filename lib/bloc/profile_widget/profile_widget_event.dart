part of 'profile_widget_bloc.dart';

@immutable
sealed class ProfileWidgetEvent {}

final class Profile extends ProfileWidgetEvent {}

final class ChangePassword extends ProfileWidgetEvent {}

final class LogOut extends ProfileWidgetEvent {
}
