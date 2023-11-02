import 'dart:io';

import 'package:dio/dio.dart';
import 'package:binav_avts/response/user_response.dart';

enum TypeMessageAuth {
  Error,
  Logout,
}

class UserDataSource {
  // final dio = Dio(BaseOptions(baseUrl: "http://127.0.0.1:8000"));
  final dio = Dio(BaseOptions(baseUrl: "https://api.binav-avts.id"));

  Future<UserResponse> login(
      {required String email, required String password}) async {
    try {
      final response = await dio
          .post("/api/login", data: {'email': email, 'password': password});
      print(response.data);
      return UserResponse.fromJson(response.data);
    } catch (e) {
      print(e);
      if (e is DioError) {
        if (e.response != null) {
          return UserResponse.fromJson(e.response!.data);
        } else {
          return throw ('Error message: ${e.message}');
        }
      }
      return throw Exception();
    }
  }

  Future<UserResponse> getUser({required String token}) async {
    try {
      dio.options.headers['Authorization'] = "Bearer $token";
      final response = await dio.get("/api/user");
      return UserResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        if (e.response != null) {
          return UserResponse.fromJson(e.response!.data);
        } else {
          return throw ('Error message: ${e.message}');
        }
      }
      return throw Exception();
    }
  }
  Future<UserResponse> logout({required String token}) async {
    try {
      dio.options.headers['Authorization'] = "Bearer $token";
      final response = await dio.post("/api/logout");
      return UserResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        if (e.response != null) {
          return UserResponse.fromJson(e.response!.data);
        } else {
          return throw ('Error message: ${e.message}');
        }
      }
      return throw Exception();
    }
  }
}
