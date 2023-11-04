import 'dart:io';

import 'package:binav_avts/response/send_response.dart';
import 'package:dio/dio.dart';
import 'package:binav_avts/response/user_response.dart';

enum TypeMessageAuth {
  Error,
  Logout,
}

class ClientDataService {
  // final dio = Dio(BaseOptions(baseUrl: "http://127.0.0.1:8000"));
  final dio = Dio(BaseOptions(baseUrl: "https://api.binav-avts.id"));

  Future<SendResponse> addClient(
      {required String client_name,
      required String email,
      required String password,
      required String password_confirmation,
      required bool isSwitched}) async {
    try {
      final response = await dio.post("/api/insert_client", data: {
        'client_name': client_name,
        'email': email,
        'password': password,
        'password_confirmation': password_confirmation,
        'status': isSwitched == true ? '1': '0',
      });
      print(response.data);
      return SendResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        if (e.response != null) {
          return SendResponse.fromJson(e.response!.data);
        } else {
          return throw ('Error message: ${e.message}');
        }
      }
      return throw Exception();
    }
  }
  Future<SendResponse> editClient(
      {required String id_client,
      required String client_name,
      required String email,
      required bool isSwitched}) async {
    try {
      final response = await dio.post("/api/update_client", data: {
        'id_client': id_client,
        'client_name': client_name,
        'email': email,
        'status': isSwitched == true ? '1': '0',
      });
      print(response.data);
      return SendResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        if (e.response != null) {
          return SendResponse.fromJson(e.response!.data);
        } else {
          return throw ('Error message: ${e.message}');
        }
      }
      return throw Exception();
    }
  }

  Future<SendResponse> deleteClient({required String token,required String id_client}) async {
    try {
      dio.options.headers['Authorization'] = "Bearer $token";
      final response = await dio.post("/api/delete_client/$id_client");
      return SendResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        if (e.response != null) {
          return SendResponse.fromJson(e.response!.data);
        } else {
          return throw ('Error message: ${e.message}');
        }
      }
      return throw Exception();
    }
  }
  Future<SendResponse> sendMailToClient({required String token,required String id_client}) async {
    try {
      dio.options.headers['Authorization'] = "Bearer $token";
      final response = await dio.post("/api/send_client_email/$id_client");
      return SendResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        if (e.response != null) {
          return SendResponse.fromJson(e.response!.data);
        } else {
          return throw ('Error message: ${e.message}');
        }
      }
      return throw Exception();
    }
  }

  // Future<UserResponse> logout({required String token}) async {
  //   try {
  //     dio.options.headers['Authorization'] = "Bearer $token";
  //     final response = await dio.post("/api/logout");
  //     return UserResponse.fromJson(response.data);
  //   } catch (e) {
  //     if (e is DioError) {
  //       if (e.response != null) {
  //         return UserResponse.fromJson(e.response!.data);
  //       } else {
  //         return throw ('Error message: ${e.message}');
  //       }
  //     }
  //     return throw Exception();
  //   }
  // }
}
