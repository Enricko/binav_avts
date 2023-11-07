import 'dart:math' as math;
import 'package:binav_avts/bloc/general/general_cubit.dart';
import 'package:binav_avts/bloc/websocket/socket_cubit.dart';
import 'package:binav_avts/response/websocket/kapalcoor_response.dart' as KapalcoorResponse;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MarkerVessel extends StatefulWidget {
  const MarkerVessel({super.key, required this.currentZoom, required this.mapController});
  final num currentZoom;
  final MapController mapController;

  @override
  State<MarkerVessel> createState() => _MarkerVesselState();
}

class _MarkerVesselState extends State<MarkerVessel> with TickerProviderStateMixin {
  final int predictMovementVessel = 1;
  KapalcoorResponse.Data? vesselClicked;

  double vesselSizes(String size) {
    switch (size) {
      case "small":
        return 4.0;
      case "medium":
        return 8.0;
      case "large":
        return 12.0;
      case "extra_large":
        return 16.0;
      default:
        return 8.0;
    }
  }

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

  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = widget.mapController.camera;
    final latTween = Tween<double>(begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    final Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    final startIdWithTarget = '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= widget.mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  Future<void> searchVessel(KapalcoorResponse.Data vessel) async {
    BlocProvider.of<GeneralCubit>(context).vesselClick = vessel;
    Future.delayed(const Duration(seconds: 1), () {
      // readNotifier.initLatLangCoor(call_sign: callSign);
      _animatedMapMove(
          LatLng(
            vessel.coor!.coorGga!.latitude!.toDouble() - .005,
            vessel.coor!.coorGga!.longitude!.toDouble(),
          ),
          15);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<KapalcoorResponse.KapalcoorResponse>(
      stream: BlocProvider.of<SocketCubit>(context).KapalCoorMarkerStreamController,
      builder: (BuildContext context, AsyncSnapshot<KapalcoorResponse.KapalcoorResponse> snapshot) {
        if (snapshot.hasData) {
          KapalcoorResponse.KapalcoorResponse data = snapshot.data!;
          if(BlocProvider.of<GeneralCubit>(context).vesselClicked != null){
            KapalcoorResponse.Data vesselClick = data.data!.where((element) => BlocProvider.of<GeneralCubit>(context).vesselClicked!.kapal!.callSign == element.kapal!.callSign!).first;
            BlocProvider.of<GeneralCubit>(context).vesselClick = vesselClick;
          }
          return MarkerLayer(
            markers: [
              for (var i in data.data!)
                Marker(
                  width: vesselSizes(i.kapal!.size!.toString()) + widget.currentZoom.toDouble(),
                  height: vesselSizes(i.kapal!.size!.toString()) + widget.currentZoom.toDouble(),
                  point: LatLng(
                      predictLatLong(
                              i.coor!.coorGga!.latitude!.toDouble(),
                              i.coor!.coorGga!.longitude!.toDouble(),
                              100,
                              i.coor!.coorHdt!.headingDegree ?? i.coor!.defaultHeading!.toDouble(),
                              predictMovementVessel)
                          .latitude,
                      predictLatLong(
                              i.coor!.coorGga!.latitude!.toDouble(),
                              i.coor!.coorGga!.longitude!.toDouble(),
                              100,
                              i.coor!.coorHdt!.headingDegree ?? i.coor!.defaultHeading!.toDouble(),
                              predictMovementVessel)
                          .longitude),
                  // rotateOrigin: const Offset(10, -10),
                  child: GestureDetector(
                    onTap: () {
                      searchVessel(i);
                      // value.vesselClicked(i.kapal!.callSign!,context);
                    },
                    child: Transform.rotate(
                      angle: degreesToRadians(i.coor!.coorHdt!.headingDegree ?? i.coor!.defaultHeading!.toDouble()),
                      child: Tooltip(
                        message: i.kapal!.callSign!.toString(),
                        child: Image.asset(
                          "assets/ship.png",
                          height: vesselSizes(i.kapal!.size!.toString()) + widget.currentZoom.toDouble(),
                          width: vesselSizes(i.kapal!.size!.toString()) + widget.currentZoom.toDouble(),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }
        return SizedBox();
      },
    );
  }
}
