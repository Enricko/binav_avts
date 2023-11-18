import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
// import 'dart:html' as html;

import 'package:binav_avts/page/tables/pipeline/add_form.dart';
import 'package:binav_avts/page/tables/pipeline/edit_form.dart';
import 'package:binav_avts/response/send_response.dart';
import 'package:dio/dio.dart';
import 'package:binav_avts/response/user_response.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class PipelineDataService {
  // final dio = Dio(BaseOptions(baseUrl: "http://127.0.0.1:8000"));
  final dio = Dio(BaseOptions(baseUrl: "https://api.binav-avts.id", headers: {
    'Accept': "application/json",
  }));

  Future<SendResponse> addPipeline(
      {required String id_client,
      required String name,
      required Uint8List file,
      required String fileName,
      required bool isSwitched}) async {
    try {
      var formData = FormData.fromMap({
        "id_client": id_client,
        "name": name,
        "file": MultipartFile.fromBytes(file, filename: fileName),
        "switch": isSwitched ? "1" : "0"
      });
      final response = await dio.post("/api/insert_mapping", data: formData, onSendProgress: (int sent, int total) {
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

  Future<SendResponse> editPipeline(
      {required String id_mapping,
      required String name,
      required Uint8List file,
      required String fileName,
      required bool isSwitched}) async {
    try {
      var formData = FormData.fromMap({
        "id_mapping": id_mapping,
        "name": name,
        "file": MultipartFile.fromBytes(file, filename: fileName),
        "switch": isSwitched ? "1" : "0"
      });
      final response = await dio.post("/api/update_mapping", data: formData, onSendProgress: (int sent, int total) {
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

  Future<SendResponse> editPipelineNoFile(
      {required String id_mapping, required String name, required bool isSwitched}) async {
    try {
      var formData = FormData.fromMap({"id_mapping": id_mapping, "name": name, "switch": isSwitched ? "1" : "0"});
      final response = await dio.post("/api/update_mapping", data: formData, onSendProgress: (int sent, int total) {
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

  Future<SendResponse> deletePipeline({required String token, required String id_mapping}) async {
    try {
      dio.options.headers['Authorization'] = "Bearer $token";
      final response = await dio.post("/api/delete_mapping/$id_mapping", onSendProgress: (int sent, int total) {
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
