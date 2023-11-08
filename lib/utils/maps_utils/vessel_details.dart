import 'dart:async';
import 'dart:math' as math;

import 'package:binav_avts/bloc/general/general_cubit.dart';
import 'package:binav_avts/utils/draw/vessel_draw.dart';
import 'package:binav_avts/utils/snipping_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:latlong2/latlong.dart';

import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:binav_avts/response/websocket/kapalcoor_response.dart' as KapalcoorResponse;

class VesselDetail extends StatefulWidget {
  const VesselDetail({super.key});
  @override
  State<VesselDetail> createState() => _VesselDetailState();
}

class _VesselDetailState extends State<VesselDetail> {
  final SnappingSheetController snappingSheetController = SnappingSheetController();
  final int predictMovementVessel = 1;

  LatLng predictLatLong(double latitude, double longitude, double speed, double course, int movementTime) {
    // Convert course from degrees to radians
    double courseRad = degreesToRadians(course);
    // Convert speed from meters per minute to meters per second
    double speedMps = speed / 60.0;
    // Calculate the distance traveled in meters
    double distanceM = speedMps * movementTime;
    // Calculate the change in latitude and longitude
    double deltaLatitude = distanceM * math.cos(courseRad) / 111111.1;
    double deltaLongitude = distanceM * math.sin(courseRad) / (111111.1 * math.cos(degreesToRadians(latitude)));
    // Calculate the new latitude and longitude
    double newLatitude = latitude + deltaLatitude;
    double newLongitude = longitude + deltaLongitude;
    return LatLng(newLatitude, newLongitude);
  }

  double degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  @override
  void initState() {
    super.initState();
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    KapalcoorResponse.Data vesselData = BlocProvider.of<GeneralCubit>(context).vesselClicked!;
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 600,
        ),
        child: SnappingSheet(
          controller: snappingSheetController,
          // child: Background(),
          lockOverflowDrag: true,
          snappingPositions: [
            SnappingPosition.factor(
              snappingCurve: Curves.elasticOut,
              snappingDuration: const Duration(milliseconds: 1750),
              positionFactor: (301.74 / MediaQuery.of(context).size.height),
            ),
            const SnappingPosition.factor(
              positionFactor: 0.0,
              snappingCurve: Curves.easeOutExpo,
              snappingDuration: Duration(seconds: 1),
              grabbingContentOffset: GrabbingContentOffset.top,
            ),
            SnappingPosition.factor(
              snappingCurve: Curves.elasticOut,
              snappingDuration: const Duration(milliseconds: 1750),
              positionFactor: (500 / MediaQuery.of(context).size.height),
            ),
            // SnappingPosition.factor(
            //   grabbingContentOffset:
            //       GrabbingContentOffset.bottom,
            //   snappingCurve: Curves.easeInExpo,
            //   snappingDuration: Duration(seconds: 1),
            //   positionFactor: 0.9,
            // ),
          ],
          grabbing: GrabbingWidget(),
          grabbingHeight: 75,
          sheetAbove: null,
          sheetBelow: SnappingSheetContent(
            draggable: true,
            // childScrollController: listViewController,
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        snappingSheetController.snapToPosition(
                          const SnappingPosition.factor(positionFactor: -0.5),
                        );
                        Timer(const Duration(milliseconds: 300), () {
                          BlocProvider.of<GeneralCubit>(context).removeVesselClick = true;
                        });
                      },
                      child: Container(
                        alignment: Alignment.topRight,
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(color: Colors.black12),
                          padding: const EdgeInsets.all(4),
                          child: const Center(
                            child: Text(
                              "X",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${vesselData.kapal!.callSign}",
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${vesselData.kapal!.flag}",
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          Image.asset(
                            "assets/model_kapal.jpg",
                            width: 100,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Position Information".toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 1)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Latitude',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(255, 61, 61, 61),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        "${predictLatLong(vesselData.coor!.coorGga!.latitude!.toDouble(), vesselData.coor!.coorGga!.longitude!.toDouble(), 100, vesselData.coor!.coorHdt!.headingDegree ?? vesselData.coor!.defaultHeading!, predictMovementVessel).latitude.toStringAsFixed(5)}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromARGB(255, 61, 61, 61),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 1)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Longitude',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(255, 61, 61, 61),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        "${predictLatLong(vesselData.coor!.coorGga!.latitude!.toDouble(), vesselData.coor!.coorGga!.longitude!.toDouble(), 100, vesselData.coor!.coorHdt!.headingDegree ?? vesselData.coor!.defaultHeading!, predictMovementVessel).longitude.toStringAsFixed(5)}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromARGB(255, 61, 61, 61),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      "Vessel",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    VesselDrawer(link: vesselData.kapal!.xmlFile!.toString().replaceAll("\/", "/")),
                    // link: "https://client-project.enricko.site/storage/xml/2023_10_15_05_45_50_asqw33388.xml"),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
