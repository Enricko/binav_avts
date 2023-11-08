import 'package:binav_avts/services/user_dataservice.dart';
import 'package:binav_avts/response/user_response.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserDataService userDataSource;
  UserBloc({required this.userDataSource}) : super(UserSignedOut()) {
    on<SignIn>((event, emit) async {
      if(state is UserSignedOut){
        final getUser = await userDataSource.login(email: event.email, password: event.password);

        if(getUser.message!.contains("Login Success")){
          SharedPreferences pref = await SharedPreferences.getInstance();
          if(getUser.client!.idClient != null){
            pref.setString('idClient', getUser.client!.idClient!);
          }
          pref.setString('idUser', getUser.user!.idUser!);
          pref.setString('email', event.email);
          pref.setString('token', getUser.token!);

          emit(UserSignedIn(user:getUser));
          await EasyLoading.dismiss();
        }else{
          emit(UserSignedOut());
          emit(UserSignedOut(message:getUser.message!,type: TypeMessageAuth.Error));
        }
      }
    });
    on<SignOut>((event, emit) async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      try { 
        final getUser = await userDataSource.logout(token: pref.getString("token").toString());
        pref.remove('idClient');
        pref.remove('idUser');
        pref.remove('email');
        pref.remove('token');
        if (getUser.message != null) {
          emit(UserSignedOut(message: getUser.message!,type: TypeMessageAuth.Logout));
        } else {
          emit(UserSignedOut());
        }
      } catch (e) {
        print(e); 
      }

    });
    on<CheckSignInStatus>((event, emit)async{
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? email = pref.getString("email");
      String? token = pref.getString("token");
      print(token);

      if(email != null && token != null){
        final getUser = await userDataSource.getUser(token:token);

        if(getUser.token != null){
          emit(UserSignedIn(user:getUser));  
        }else{
          emit(UserSignedOut(message: "Authentication session are over!!")); 
        }
      }else{
        emit(UserSignedOut()); 
      }
    });
  }
}
