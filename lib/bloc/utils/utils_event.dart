part of 'utils_bloc.dart';

@immutable
sealed class UtilsEvent {}

final class CheckboxEvent extends UtilsEvent {
  List<Object?> get props => [];
}
