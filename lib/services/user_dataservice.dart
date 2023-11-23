import 'dart:io';

import 'package:dio/dio.dart';
import 'package:binav_avts/response/user_response.dart';

enum TypeMessageAuth {
  Error,
  Logout,
}

class UserDataService {
  // final dio = Dio(BaseOptions(baseUrl: "http://127.0.0.1:8000"));
  final dio = Dio(BaseOptions(baseUrl: "https://api.binav-avts.id", headers: {
    'Accept': "application/json",
  }));

  Future<UserResponse> login({required String email, required String password}) async {
    try {
      final response = await dio.post("/api/login", data: {'email': email, 'password': password});
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

  Future<UserResponse> changePassword({required String token, required Map<String, dynamic> data}) async {
    try {
      dio.options.headers['Authorization'] = "Bearer $token";
      // final response = await dio.post("/api/changePassword");
      var formData = FormData.fromMap({
        "old_password": data['old_password'],
        "new_password": data['new_password'],
        "password_confirmation": data['password_confirmation']
      });
      final response = await dio.post("/api/change", data: formData);
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

  Future<UserResponse> forgotPassword({required String email}) async {
    try {
      final response = await dio.post("/api/password/email", data: {
        'email': email,
      });
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

  Future<UserResponse> checkOtp({required String code}) async {
    try {
      final response = await dio.post("/api/password/code/check", data: {
        'code': code,
      });
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

  Future<UserResponse> resetPassword({required Map<String, dynamic> data}) async {
    try {
      var formData = FormData.fromMap(
          {"code": data['code'], "password": data['password'], "password_confirmation": data['password_confirmation']});
      final response = await dio.post("/api/password/reset", data: formData);
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
