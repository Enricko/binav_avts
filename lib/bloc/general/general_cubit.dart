import 'package:binav_avts/page/screen/forgot_password/send_email_confirmation.dart';
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

  // bool _isForgotPassword = true;
  // bool? get isForgotPassword => _isForgotPassword;



  Widget _forgotPasswordContent = SendEmailConfirm();
  Widget get forgotPasswordContent =>  _forgotPasswordContent;

  set changeContent(Widget content){
    _forgotPasswordContent = content;
  }

}
