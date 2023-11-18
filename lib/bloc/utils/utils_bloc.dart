import 'package:binav_avts/services/user_dataservice.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:meta/meta.dart';

part 'utils_event.dart';
part 'utils_state.dart';

class UtilsBloc extends Cubit<CheckboxState> {
  UtilsBloc() : super(CheckboxState.checked);

  void toggleCheckbox() {
    state == CheckboxState.checked
        ? emit(CheckboxState.unchecked)
        : emit(CheckboxState.checked);
  }
}