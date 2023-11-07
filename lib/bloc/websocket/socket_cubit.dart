import 'dart:async';
import 'dart:convert';

import 'package:binav_avts/response/websocket/client_response.dart';
import 'package:binav_avts/response/websocket/ipkapal_response.dart';
import 'package:binav_avts/response/websocket/kapal_response.dart';
import 'package:binav_avts/response/websocket/kapalcoor_response.dart';
import 'package:binav_avts/response/websocket/mapping_response.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'socket_state.dart';

enum TypeSocket {
  client,
  mapping,
  kapal,
  kapalcoor,
  ipkapal,
}

class SocketCubit extends Cubit<SocketState> {
  // String url =
  //     // "wss://api.binav-avts.id:6001/socket-client?appKey=123456";
  //     "ws://127.0.0.1:6001/?appKey=123456";
  final WebSocketChannel _channel =
      WebSocketChannel.connect(Uri.parse("wss://api.binav-avts.id:6001/?appKey=123456"));
  SocketCubit() : super(SocketInitial());

  
  // === Client Table ===
  final _clientTableStreamController = StreamController<ClientResponse>.broadcast();

  // ignore: non_constant_identifier_names
  Stream<ClientResponse> get ClientTableStreamController =>
      _clientTableStreamController.stream;
  
  // === Mapping Table ===
  final _mappingTableStreamController = StreamController<MappingResponse>.broadcast();

  // ignore: non_constant_identifier_names
  Stream<MappingResponse> get MappingTableStreamController =>
      _mappingTableStreamController.stream;

  // === Mapping Layer ===
  final _mappingLayerStreamController = StreamController<MappingResponse>.broadcast();

  // ignore: non_constant_identifier_names
  Stream<MappingResponse> get MappingLayerStreamController =>
      _mappingLayerStreamController.stream;

  // === Kapal Table ===
  final _kapalTableStreamController = StreamController<KapalResponse>.broadcast();

  // ignore: non_constant_identifier_names
  Stream<KapalResponse> get KapalTableStreamController =>
      _kapalTableStreamController.stream;

  // === Kapal Table ===
  final _ipKapalTableStreamController = StreamController<IpkapalResponse>.broadcast();

  // ignore: non_constant_identifier_names
  Stream<IpkapalResponse> get IpKapalTableStreamController =>
      _ipKapalTableStreamController.stream;
  
  final _kapalCoorMarkerStreamController = StreamController<KapalcoorResponse>.broadcast();

  // ignore: non_constant_identifier_names
  Stream<KapalcoorResponse> get KapalCoorMarkerStreamController =>
      _kapalCoorMarkerStreamController.stream;


  void getClientDataTable({required Map<String, dynamic> payload}) {
    payload.addAll({
      "type": "client",
      "id_response": 1,
    });
    _channel.sink.add(json.encode(payload));
  }
  void getMappingDataTable({required Map<String, dynamic> payload}) {
    payload.addAll({
      "type": "mapping",
      "id_response": 1,
    });
    _channel.sink.add(json.encode(payload));
  }
  void getKapalDataTable({required Map<String, dynamic> payload}) {
    payload.addAll({
      "type": "kapal",
      "id_response": 1,
    });
    _channel.sink.add(json.encode(payload));
  }
  

  void getIPKapalDataTable({required Map<String, dynamic> payload}) {
    payload.addAll({
      "type": "ipkapal",
      "id_response": 1,
    });
    _channel.sink.add(json.encode(payload));
  }

  void getKapalCoorDataMarker({required Map<String, dynamic> payload}) {
    payload.addAll({
      "type": "kapalcoor",
      "id_response": 1,
    });
    _channel.sink.add(json.encode(payload));
  }

  void getMappingLayer({required Map<String, dynamic> payload}) {
    payload.addAll({
      "type": "mapping",
      "id_response": 2,
    });
    _channel.sink.add(json.encode(payload));
  }

  void listen() {
    _channel.stream.listen((event) {
      if(event != "on Opened"){
        Map<String, dynamic> message = jsonDecode(event);

        // === Client Listener ===
        if(TypeSocket.client.name.toLowerCase() == message['type'].toString().toLowerCase()){
          if(message['id_response'] == '1') {
            _clientTableStreamController.sink.add(ClientResponse.fromJson(message));
          }
        }

        // === Mapping Listener ===
        if(TypeSocket.mapping.name.toLowerCase() == message['type'].toString().toLowerCase()) {
          if(message['id_response'] == '1') {
            _mappingTableStreamController.sink.add(MappingResponse.fromJson(message));
          }
          if(message['id_response'] == '2') {
            _mappingLayerStreamController.sink.add(MappingResponse.fromJson(message));
          }
        }

        // === Kapal Listener ===
        if(TypeSocket.kapal.name.toLowerCase() == message['type'].toString().toLowerCase()) {
          if(message['id_response'] == '1') {
            _kapalTableStreamController.sink.add(KapalResponse.fromJson(message));
          }
        }

        // === IP Kapal Listener ===
        if(TypeSocket.ipkapal.name.toLowerCase() == message['type'].toString().toLowerCase()) {
          if(message['id_response'] == '1') {
            _ipKapalTableStreamController.sink.add(IpkapalResponse.fromJson(message));
          }
        }
        
        // === IP Kapal Listener ===
        if(TypeSocket.kapalcoor.name.toLowerCase() == message['type'].toString().toLowerCase()) {
          if(message['id_response'] == '1') {
            _kapalCoorMarkerStreamController.sink.add(KapalcoorResponse.fromJson(message));
          }
        }
      }
    });
  }
  
  @override
  Future<void> close() {
    _channel.sink.close();
    return super.close();
  }
}
