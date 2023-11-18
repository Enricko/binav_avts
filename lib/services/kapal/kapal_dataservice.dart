import 'dart:io';
import 'dart:typed_data';

import 'package:binav_avts/response/send_response.dart';
import 'package:dio/dio.dart';
import 'package:binav_avts/response/user_response.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

enum TypeMessageAuth {
  Error,
  Logout,
}

class KapalDataService {
  // final dio = Dio(BaseOptions(baseUrl: "http://127.0.0.1:8000"));
  final dio = Dio(BaseOptions(baseUrl: "https://api.binav-avts.id", headers: {
    'Accept': "application/json",
  }));

  Future<SendResponse> addKapal({
    required Uint8List file,
    required String fileName,
    required bool isSwitched,
    required Map<String, dynamic> data,
  }) async {
    try {
      var formData = FormData.fromMap({
        "id_client": data['id_client'],
        "call_sign": data['call_sign'],
        "flag": data['flag'],
        "class": data['class'],
        "builder": data['builder'],
        "year_built": data['year_built'],
        "size": data['size'],
        "xml_file": MultipartFile.fromBytes(file, filename: fileName),
        "status": isSwitched ? "1" : "0"
      });
      final response = await dio.post("/api/insert_kapal", data: formData, onSendProgress: (int sent, int total) {
        EasyLoading.showProgress(sent / total,
            status: "${((sent / total) * 100).toStringAsFixed(2)}%\nSending data...");
      });
      return SendResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        if (e.response != null) {
          return SendResponse.fromJson(e.response!.data);
        } else {
          return throw ('Error message: ${e.message}');
        }
      }
      print(e);
      return throw Exception();
    }
  }

  Future<SendResponse> editKapal({
    required Uint8List file,
    required String fileName,
    required bool isSwitched,
    required Map<String, dynamic> data,
  }) async {
    try {
      var formData = FormData.fromMap({
        "old_call_sign": data['old_call_sign'],
        "call_sign": data['call_sign'],
        "flag": data['flag'],
        "class": data['class'],
        "builder": data['builder'],
        "year_built": data['year_built'],
        "size": data['size'],
        "xml_file": MultipartFile.fromBytes(file, filename: fileName),
        "status": isSwitched ? "1" : "0"
      });
      final response = await dio.post("/api/update_kapal", data: formData, onSendProgress: (int sent, int total) {
        EasyLoading.showProgress(sent / total,
            status: "${((sent / total) * 100).toStringAsFixed(2)}%\nSending data...");
      });
      return SendResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        if (e.response != null) {
          return SendResponse.fromJson(e.response!.data);
        } else {
          return throw ('Error message: ${e.message}');
        }
      }
      print(e);
      return throw Exception();
    }
  }

  Future<SendResponse> editKapalNoFile({
    required bool isSwitched,
    required Map<String, dynamic> data,
  }) async {
    try {
      var formData = FormData.fromMap({
        "old_call_sign": data['old_call_sign'],
        "call_sign": data['call_sign'],
        "flag": data['flag'],
        "class": data['class'],
        "builder": data['builder'],
        "year_built": data['year_built'],
        "size": data['size'],
        "status": isSwitched ? "1" : "0"
      });
      final response = await dio.post("/api/update_kapal", data: formData, onSendProgress: (int sent, int total) {
        EasyLoading.showProgress(sent / total,
            status: "${((sent / total) * 100).toStringAsFixed(2)}%\nSending data...");
      });
      return SendResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioError) {
        if (e.response != null) {
          return SendResponse.fromJson(e.response!.data);
        } else {
          return throw ('Error message: ${e.message}');
        }
      }
      print(e);
      return throw Exception();
    }
  }

  Future<SendResponse> deleteKapal({required String token, required String call_sign}) async {
    try {
      dio.options.headers['Authorization'] = "Bearer $token";
      final response = await dio.post("/api/delete_kapal/$call_sign", onSendProgress: (int sent, int total) {
        EasyLoading.showProgress(sent / total,
            status: "${((sent / total) * 100).toStringAsFixed(2)}%\nSending data...");
      });
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
}
