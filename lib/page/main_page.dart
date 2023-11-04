import 'dart:async';
import 'dart:convert';

import 'package:binav_avts/bloc/websocket/socket_cubit.dart';
import 'package:binav_avts/bloc/user/user_bloc.dart';
import 'package:binav_avts/bloc/websocket/socket_cubit.dart';
import 'package:binav_avts/page/tables/clients/client.dart';
import 'package:binav_avts/response/websocket/client_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.idClient = ""});
  final String idClient;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // final WebSocketDataService clientData = WebSocketDataService();
  // // final WebSocketDataService _clientData = WebSocketDataService();
  Timer? _timer;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      BlocProvider.of<SocketCubit>(context).getKapalDataTable(payload: {
        // "id_client": "lHzJTM7oz1FhePXCfTEh",
        "page": 1,
        "perpage": 10
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
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
                const PopupMenuItem(
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
                  // case "vesselList":
                  //   showDialog(
                  //       context: context,
                  //       barrierDismissible: false,
                  //       builder: (BuildContext context) {
                  //         return Dialog(
                  //             shape: const RoundedRectangleBorder(
                  //                 borderRadius:
                  //                     BorderRadius.all(Radius.circular(5))),
                  //             child: VesselPage(id_client: widget.idClient));
                  //       });
                  // case "pipelineList":
                  //   showDialog(
                  //       context: context,
                  //       barrierDismissible: false,
                  //       builder: (BuildContext context) {
                  //         var height = MediaQuery.of(context).size.height;
                  //         var width = MediaQuery.of(context).size.width;

                  //         return Dialog(
                  //           shape: const RoundedRectangleBorder(
                  //               borderRadius:
                  //                   BorderRadius.all(Radius.circular(5))),
                  //           child: PipelinePage(id_client: widget.idClient),
                  //         );
                  //       });
                  case "clientList":
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          var height = MediaQuery.of(context).size.height;
                          var width = MediaQuery.of(context).size.width;

                          return Dialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: ClientTablePage(idClient: widget.idClient),
                          );
                        });
                }
              },
            ),
            Container(
              child: Text(widget.idClient),
            ),
          ],
        ),
      ),
      body: Center(
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Main Page'),
                    const SizedBox(
                      height: 20,
                    ),
                    // StreamBuilder(
                    //     stream: BlocProvider.of<SocketCubit>(context).KapalTableStreamController,
                    //     builder: (context, snapshot) {
                    //       if (snapshot.hasData) {
                    //         return Text(jsonEncode(snapshot.data));
                    //       }
                    //       return Container();
                    //     }),
                    Text(state is UserSignedIn
                        ? state.user.user!.name.toString()
                        : ""),
                    Text(state is UserSignedIn
                        ? state.user.user!.email.toString()
                        : ""),
                    Text(state is UserSignedIn
                        ? state.user.user!.idUser.toString()
                        : ""),
                    Text(state is UserSignedIn
                        ? state.user.client!.idClient.toString()
                        : ""),
                    ClientTablePage(),
                    ElevatedButton(
                        onPressed: () {
                          EasyLoading.show(status: "Loading...");
                          setState(() {
                            context.read<UserBloc>().add(SignOut());
                          });
                        },
                        child: const Text("Logout")),
                  ]),
            );
          },
        ),
      ),
    );
  }
}
