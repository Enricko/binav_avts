import 'dart:async';

import 'package:binav_avts/bloc/websocket/socket_cubit.dart';
import 'package:binav_avts/response/websocket/ipkapal_response.dart';
import 'package:binav_avts/response/websocket/kapal_response.dart' as KapalResponse;
import 'package:binav_avts/utils/draw/vessel_draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_ui/responsive_ui.dart';

class DetailKapal extends StatefulWidget {
  const DetailKapal({super.key, required this.data});
  final KapalResponse.Data data;

  @override
  State<DetailKapal> createState() => _DetailKapalState();
}

class _DetailKapalState extends State<DetailKapal> {
  bool load = false;
  bool ignorePointer = false;
  Timer? _timer;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      BlocProvider.of<SocketCubit>(context)
          .getIPKapalDataTable(payload: {"call_sign": widget.data.callSign, "page": 1, "perpage": 10});
      setState(() {
        load = false;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width <= 540 ? width / 1 : width / 1.7,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.black12,
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Detail Kapal | ${widget.data.callSign}",
                    style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(8),
              child: Column(
                children: [
                  Responsive(
                    children: [
                      Div(
                        divison: Division(
                          colXL: 6,
                          colL: 6,
                          colM: 6,
                          colS: 6,
                          colXS: 6,
                        ),
                        child: RichText(
                          text: TextSpan(style: TextStyle(fontSize: 15), children: [
                            TextSpan(
                              text: "Call Sign\n",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(
                              text: "\t\t${widget.data.callSign!}",
                            ),
                          ]),
                        ),
                      ),
                      Div(
                        divison: Division(
                          colXL: 6,
                          colL: 6,
                          colM: 6,
                          colS: 6,
                          colXS: 6,
                        ),
                        child: RichText(
                          text: TextSpan(style: TextStyle(fontSize: 15), children: [
                            TextSpan(
                              text: "Call Sign\n",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(
                              text: "\t\t${widget.data.callSign!}",
                            ),
                          ]),
                        ),
                      ),
                      Div(
                        divison: Division(
                          colXL: 6,
                          colL: 6,
                          colM: 6,
                          colS: 6,
                          colXS: 6,
                        ),
                        child: RichText(
                          text: TextSpan(style: TextStyle(fontSize: 15), children: [
                            TextSpan(
                              text: "Flag\n",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(
                              text: "\t\t${widget.data.flag!}",
                            ),
                          ]),
                        ),
                      ),
                      Div(
                        divison: Division(
                          colXL: 6,
                          colL: 6,
                          colM: 6,
                          colS: 6,
                          colXS: 6,
                        ),
                        child: RichText(
                          text: TextSpan(style: TextStyle(fontSize: 15), children: [
                            TextSpan(
                              text: "Class\n",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(
                              text: "\t\t${widget.data.kelas!}",
                            ),
                          ]),
                        ),
                      ),
                      Div(
                        divison: Division(
                          colXL: 6,
                          colL: 6,
                          colM: 6,
                          colS: 6,
                          colXS: 6,
                        ),
                        child: RichText(
                          text: TextSpan(style: TextStyle(fontSize: 15), children: [
                            TextSpan(
                              text: "Year Built\n",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(
                              text: "\t\t${widget.data.yearBuilt!}",
                            ),
                          ]),
                        ),
                      ),
                      Div(
                        divison: Division(
                          colXL: 6,
                          colL: 6,
                          colM: 6,
                          colS: 6,
                          colXS: 6,
                        ),
                        child: RichText(
                          text: TextSpan(style: TextStyle(fontSize: 15), children: [
                            TextSpan(
                              text: "Size\n",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(
                              text: "\t\t${widget.data.size!}",
                            ),
                          ]),
                        ),
                      ),
                      Div(
                        divison: Division(
                          colXL: 6,
                          colL: 6,
                          colM: 6,
                          colS: 6,
                          colXS: 6,
                        ),
                        child: RichText(
                          text: TextSpan(style: TextStyle(fontSize: 15), children: [
                            TextSpan(
                              text: "Status\n",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(
                              text: "\t\t${widget.data.status! ? 'ON' : 'OFF'}",
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  VesselDrawer(link: widget.data.xmlFile!.toString().replaceAll("\/", "/")),
                  StreamBuilder<IpkapalResponse>(
                    stream: BlocProvider.of<SocketCubit>(context).IpKapalTableStreamController,
                    builder: (context, AsyncSnapshot<IpkapalResponse> snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text("Something went wrong"),
                        );
                      }
                      if (load) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasData) {
                        IpkapalResponse data = snapshot.data!;
                        return Container(
                          width: double.infinity,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                                headingRowColor: MaterialStateProperty.all(Color(0xffd3d3d3)),
                                columns: const [
                                  DataColumn(label: SizedBox(width: 210, child: Text("IP"))),
                                  DataColumn(label: Text("Port")),
                                  DataColumn(label: Text("Type")),
                                ],
                                rows: data.data!.map((value) {
                                  return DataRow(cells: [
                                    DataCell(Text(value.ip!)),
                                    DataCell(Text(value.port!)),
                                    DataCell(Text(value.typeIp!)),
                                  ]);
                                }).toList()),
                          ),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
