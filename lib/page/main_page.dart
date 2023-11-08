import 'dart:async';
import 'dart:math' as math;

import 'package:binav_avts/bloc/general/general_cubit.dart';
import 'package:binav_avts/bloc/user/user_bloc.dart';
import 'package:binav_avts/bloc/websocket/socket_cubit.dart';
import 'package:binav_avts/page/profile_page.dart';
import 'package:binav_avts/page/tables/clients/client.dart';
import 'package:binav_avts/page/tables/kapal/kapal.dart';
import 'package:binav_avts/page/tables/pipeline/pipeline.dart';
import 'package:binav_avts/utils/constants.dart';
import 'package:binav_avts/utils/maps_utils/pipeline_layer.dart';
import 'package:binav_avts/utils/maps_utils/vessel.dart';
import 'package:binav_avts/utils/maps_utils/vessel_details.dart';
import 'package:binav_avts/utils/scale_bar/scale_bar.dart';
import 'package:binav_avts/utils/zoom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.idClient = ""});
  final String idClient;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late final MapController mapController;

  final pointSize = 75.0;
  final pointY = 75.0;

  LatLng? latLng;

  int vesselTotal = 0;

  num currentZoom = 15.0;
  // final WebSocketDataService clientData = WebSocketDataService();
  // // final WebSocketDataService _clientData = WebSocketDataService();
  Timer? _timer;

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

  void updatePoint(MapEvent? event, BuildContext context) {
    final pointX = Constants.getPointX(context);
    setState(() {
      latLng = mapController.camera.pointToLatLng(math.Point(pointX, pointY));
    });
  }

  // Animated Map Variable
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = mapController.camera;
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

      hasTriggeredMove |= mapController.move(
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
  

  @override
  void initState() {
    super.initState();
    BlocProvider.of<SocketCubit>(context).getKapalCoorDataMarker(payload: {
      "id_client": widget.idClient,
      "page": 1,
      "perpage": 100
    });
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      BlocProvider.of<SocketCubit>(context).getKapalCoorDataMarker(payload: {
        "id_client": widget.idClient,
        "page": 1,
        "perpage": 100
      });
    });

    mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updatePoint(null, context);
    });
  }

  // @override
  // void dispose() {
  //   // _timer!.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context,state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF0E286C),
            iconTheme: const IconThemeData(
              color: Colors.white, // Change this color to the desired color
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PopupMenuButton(
                  position: PopupMenuPosition.under,
                  icon: const Icon(Icons.menu),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'vesselList',
                      child: Text('Vessel List'),
                    ),
                    const PopupMenuItem(
                      value: 'pipelineList',
                      child: Text('Pipeline List'),
                    ),
                    const PopupMenuItem(
                      value: 'clientList',
                      child: Text('Client List'),
                    ),
                  ],
                  onSelected: (item) {
                    switch (item) {
                      case "vesselList":
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Dialog(
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                  child: KapalTablePage(idClient: widget.idClient));
                            });
                      case "pipelineList":
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                child: PipelineTablePage(idClient: widget.idClient),
                              );
                            });
                      case "clientList":
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                child: ClientTablePage(idClient: widget.idClient),
                              );
                            });
                    }
                  },
                ),
                GestureDetector(
                    onTap: (){
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Dialog(
                              alignment: Alignment.centerRight,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                child:ProfilePage());
                          });
                    },
                    child: CircleAvatar(
                      child: Text((state is UserSignedIn) ? state.user.user!.name![0] : "",style: TextStyle(fontSize: 15) ),
                    ))
                // Text(widget.idClient,style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          body: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Flexible(
                      child: FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          onMapEvent: (event) {
                            updatePoint(null, context);
                          },
                          minZoom: 4,
                          maxZoom: 18,
                          initialZoom: 10,
                          initialCenter: const LatLng(-1.089955, 117.360343),
                          onPositionChanged: (position, hasGesture) {
                            setState(() {
                              currentZoom = (position.zoom! - 8) * 5;
                            });
                            // readNotifier.vesselSize(position.zoom!,vesselSizes());
                          },
                        ),
                        nonRotatedChildren: [
                          /// button zoom in/out kanan bawah
                          const FlutterMapZoomButtons(
                            minZoom: 4,
                            maxZoom: 18,
                            mini: true,
                            padding: 10,
                            alignment: Alignment.bottomRight,
                          ),

                          /// widget skala kiri atas
                          ScaleLayerWidget(
                            options: ScaleLayerPluginOption(
                              lineColor: Colors.blue,
                              lineWidth: 2,
                              textStyle: const TextStyle(color: Colors.blue, fontSize: 12),
                              padding: const EdgeInsets.all(10),
                            ),
                          ),

                          /// widget berisi detail informasi kapal
                          if (BlocProvider.of<GeneralCubit>(context).vesselClicked != null)
                            VesselDetail(),
                        ],
                        children: [
                          TileLayer(
                            urlTemplate:
                                // Google RoadMap
                                // 'https://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}&User-Agent=BinavAvts/1.0',
                                // Google Altered roadmap
                                // 'https://mt0.google.com/vt/lyrs=r&hl=en&x={x}&y={y}&z={z}',
                                // Google Satellite
                                // 'https://mt0.google.com/vt/lyrs=s&hl=en&x={x}&y={y}&z={z}',
                                // Google Terrain
                                // 'https://mt0.google.com/vt/lyrs=p&hl=en&x={x}&y={y}&z={z}',
                                // Google Hybrid
                                'https://mt0.google.com/vt/lyrs=y&hl=en&x={x}&y={y}&z={z}&User-Agent=BinavAvts/1.0',
                            // Open Street Map
                            // 'https://c.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                            tileProvider: CancellableNetworkTileProvider(),
                          ),
                          MarkerLayer(
                            markers: [
                              if (latLng != null)
                                Marker(
                                  width: pointSize,
                                  height: pointSize,
                                  point: latLng!,
                                  child: Image.asset(
                                    "assets/compass.png",
                                    width: 250,
                                    height: 250,
                                  ),
                                ),
                            ],
                          ),

                          // Pipeline Layers (utils/maps_utils/pipeline_layer.dart)
                          PipelineLayer(idClient:widget.idClient),
                          MarkerVessel(mapController: mapController,currentZoom: currentZoom),
                        ],
                      ),
                    ),

                    // ElevatedButton(
                    //   onPressed: () {
                    //     EasyLoading.show(status: "Loading...");
                    //     setState(() {
                    //       context.read<UserBloc>().add(SignOut());
                    //     });
                    //   },
                    //   child: const Text("Logout"),
                    // ),
                  ],
                ),
              )
        );
      }
    );
  }
}
