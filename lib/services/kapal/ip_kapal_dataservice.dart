import 'dart:io';
import 'dart:typed_data';

import 'package:binav_avts/response/send_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

enum TypeMessageAuth {
  Error,
  Logout,
}

class IpKapalDataService {
  // final dio = Dio(BaseOptions(baseUrl: "http://127.0.0.1:8000"));
  final dio = Dio(BaseOptions(baseUrl: "https://api.binav-avts.id", headers: {
    'Accept': "application/json",
  }));
  
  Future<SendResponse> addIpKapal({
    required String callSign,
    required String ip,
    required String port,
    required String type,
  }) async {
    try {
      var formData = FormData.fromMap({
        'call_sign': callSign,
        'ip': ip,
        'port': port,
        'type_ip': type,
      });
      final response = await dio.post("/api/insert_kapal_ip", data: formData, onSendProgress: (int sent, int total) {
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

  Future<SendResponse> deleteIpKapal({required String token, required String idIpKapal}) async {
    try {
      dio.options.headers['Authorization'] = "Bearer $token";
      final response = await dio.post("/api/delete_kapal_ip/$idIpKapal", onSendProgress: (int sent, int total) {
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
