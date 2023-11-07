import 'dart:async';
import 'dart:convert';

import 'package:binav_avts/bloc/websocket/socket_cubit.dart';
import 'package:binav_avts/response/websocket/mapping_response.dart' as MappingResponse;
import 'package:binav_avts/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class PipelineLayer extends StatefulWidget {
  const PipelineLayer({super.key, this.idClient = ""});
  final String idClient;

  @override
  State<PipelineLayer> createState() => _PipelineLayerState();
}

class KmlPolygon {
  final List<LatLng> points;
  final String color;

  KmlPolygon({required this.points, required this.color});
}

class _PipelineLayerState extends State<PipelineLayer> {
  Map<String, List<KmlPolygon>> kmlOverlayPolygons = {};
  Timer? _timer;

  Future<void> loadKMZData(BuildContext context, List<MappingResponse.Data> files) async {
    try {
      for (var data in files) {
        String file = data.file!;
        if (!kmlOverlayPolygons.containsKey(file.toString()) && file.isNotEmpty) {
          if (data.onOff == true) {
            // final response = await http.get(Uri.parse(data.file!),headers: {'Accept': 'application/xml'});
            final response = await http.get(Uri.parse(file));
            if (file.endsWith(".kmz")) {
              if (response.statusCode == 200) {
                final kmlData = Constants.extractKMLDataFromKMZ(response.bodyBytes);
                if (kmlData != null) {
                  kmlOverlayPolygons[file.toString()] = parseKmlForOverlay(kmzData: kmlData);
                }
              } else {
                throw Exception('Failed to load KMZ data: ${response.statusCode}');
              }
            } else if (file.endsWith(".kml")) {
              kmlOverlayPolygons[file.toString()] = parseKmlForOverlay(kmlData: response.body);
            }
          } else {
            continue;
          }
        }
      }
    } catch (e) {
      print(e);
    }
    // print(kmlOverlayPolygons.length);
  }

  List<KmlPolygon> parseKmlForOverlay({List<int>? kmzData, String? kmlData}) {
    final List<KmlPolygon> polygons = [];
    xml.XmlDocument? doc;

    if (kmzData != null) {
      doc = xml.XmlDocument.parse(utf8.decode(kmzData));
    } else if (kmlData != null) {
      doc = xml.XmlDocument.parse(kmlData);
    }

    final Iterable<xml.XmlElement> placemarks = doc!.findAllElements('Placemark');
    for (final placemark in placemarks) {
      final xml.XmlElement? extendedDataElement = placemark.getElement("ExtendedData");
      final xml.XmlElement? schemaDataElement = extendedDataElement!.getElement("SchemaData");
      final Iterable<xml.XmlElement> simpleDataElement = schemaDataElement!.findAllElements("SimpleData");
      final subClass =
          simpleDataElement.where((element) => element.getAttribute("name") == "SubClasses").first.innerText;
      if (subClass == "AcDbEntity:AcDb2dPolyline" || subClass == "AcDbEntity:AcDbPolyline") {
        final styleElement = placemark.findAllElements('Style').first;
        final lineStyleElement = styleElement.findElements('LineStyle').first;
        final colorLine = lineStyleElement.findElements('color').first.innerText;

        final xml.XmlElement? polygonElement = placemark.getElement('LineString');
        if (polygonElement != null) {
          final List<LatLng> polygonPoints = [];

          final xml.XmlElement? coordinatesElement = polygonElement.getElement('coordinates');
          if (coordinatesElement != null) {
            final String coordinatesText = coordinatesElement.text;
            final List<String> coordinateList = coordinatesText.split(' ');

            for (final coordinate in coordinateList) {
              final List<String> latLng = coordinate.split(',');
              if (latLng.length >= 2) {
                double? latitude = double.tryParse(latLng[1]);
                double? longitude = double.tryParse(latLng[0]);
                if (latitude != null && longitude != null) {
                  polygonPoints.add(LatLng(latitude, longitude));
                }
              }
            }
          }

          // print(placemark.getElement('styleUrl')!.text);
          if (polygonPoints.isNotEmpty) {
            polygons.add(KmlPolygon(points: polygonPoints, color: colorLine));
          }
        }
      }
    }

    return polygons;
    // MappingLayerStreamController
  }

  void fetchData() {
    BlocProvider.of<SocketCubit>(context)
        .getMappingLayer(payload: {"id_client": widget.idClient, "page": 1, "perpage": 100});
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      BlocProvider.of<SocketCubit>(context)
          .getMappingLayer(payload: {"id_client": widget.idClient, "page": 1, "perpage": 100});
      // load = false;
    });
  }

  void stopFetchingData() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  @override
  void initState() {
    fetchData();
    BlocProvider.of<SocketCubit>(context).MappingLayerStreamController.listen((event) {
      // MappingResponse.Data val = event.data;
      // final data = MappingResponse.MappingResponse.fromJson(val);
      List<MappingResponse.Data> pipeData = event.data!;
      loadKMZData(context, pipeData);
    });
    super.initState();
  }

  @override
  void dispose() {
    stopFetchingData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: kmlOverlayPolygons.entries
          .map((x) => PolylineLayer(
                polylines: x.value
                    .map(
                      (y) => Polyline(
                        strokeWidth: 3,
                        points: y.points,
                        color: Color(
                          int.parse(
                            y.color,
                            radix: 16,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ))
          .toList(),
    );
  }
}
