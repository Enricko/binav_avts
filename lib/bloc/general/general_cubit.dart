import 'package:binav_avts/response/websocket/kapalcoor_response.dart' as KapalcoorResponse;
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'general_state.dart';

class GeneralCubit extends Cubit<GeneralState> {
  GeneralCubit() : super(GeneralInitial());

  KapalcoorResponse.Data? _vesselClicked;
  KapalcoorResponse.Data? get vesselClicked =>  _vesselClicked;

  set vesselClick(KapalcoorResponse.Data data){
    _vesselClicked = data;
  }

  set removeVesselClick(bool remove){
    if(remove){
      _vesselClicked = null;
    }
  }

}
