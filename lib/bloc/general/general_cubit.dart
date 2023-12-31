import 'package:binav_avts/page/screen/forgot_password/reset_success.dart';
import 'package:binav_avts/page/screen/forgot_password/send_email_confirmation.dart';
import 'package:binav_avts/page/screen/login_page.dart';
import 'package:binav_avts/response/websocket/kapalcoor_response.dart' as KapalcoorResponse;
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

part 'general_state.dart';

class GeneralCubit extends Cubit<GeneralState> {
  GeneralCubit() : super( GeneralInitial());

  KapalcoorResponse.Data? _vesselClicked;
  KapalcoorResponse.Data? get vesselClicked =>  _vesselClicked;

  bool? get vesselClickedBool =>  _vesselClicked = null;

  set vesselClick(KapalcoorResponse.Data data){
    _vesselClicked = data;
  }

  set removeVesselClick(bool remove){
    if(remove){
      _vesselClicked = null;
    }
  }

  Widget _forgotPasswordContent = LoginPage();
  Widget get forgotPasswordContent =>  _forgotPasswordContent;

  set changeContent(Widget content){
    _forgotPasswordContent = content;
  }

  bool _isChecked = false;
  bool get isChecked =>  _isChecked;

  set checkedRemember (bool value){
    _isChecked = !_isChecked;
  }

}
