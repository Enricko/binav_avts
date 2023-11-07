import 'dart:async';

import 'package:binav_avts/bloc/websocket/socket_cubit.dart';
import 'package:binav_avts/response/websocket/ipkapal_response.dart';
import 'package:binav_avts/utils/alerts.dart';
import 'package:binav_avts/utils/constants.dart';
import 'package:binav_avts/utils/text_field.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class IpKapalPage extends StatefulWidget {
  const IpKapalPage({super.key, required this.callSign});
  final String callSign;

  @override
  State<IpKapalPage> createState() => _IpKapalPageState();
}

class _IpKapalPageState extends State<IpKapalPage> {
  TextEditingController ipController = TextEditingController();
  TextEditingController portController = TextEditingController();
  String? type;
  bool load = false;
  Timer? _timer;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      BlocProvider.of<SocketCubit>(context)
          .getIPKapalData(payload: {"call_sign": widget.callSign, "page": 1, "perpage": 10});
      setState(() {
        load = false;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    ipController.dispose();
    portController.dispose();
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width <= 540 ? width / 1.4 : width / 1.7,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.black12,
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  " Upload Ip & Port (${widget.callSign})",
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
          SizedBox(
            height: 480,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    CustomTextField(
                      controller: ipController,
                      hint: 'IP',
                      type: TextInputType.text,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 35,
                            child: TextFormField(
                              style: TextStyle(fontSize: 14),
                              controller: portController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(8, 3, 1, 3),
                                  labelText: "Port",
                                  labelStyle: Constants.labelstyle,
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 1, color: Colors.blueAccent),
                                  ),
                                  enabledBorder:
                                      OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black38)),
                                  filled: true,
                                  fillColor: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        SizedBox(
                          height: 35,
                          width: 150,
                          child: DropdownSearch<String>(
                            dropdownBuilder: (context, selectedItem) => Text(
                              selectedItem ?? "",
                              style: const TextStyle(fontSize: 15, color: Colors.black54),
                            ),
                            popupProps: PopupPropsMultiSelection.dialog(
                              fit: FlexFit.loose,
                              itemBuilder: (context, item, isSelected) => ListTile(
                                title: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: "Type",
                                labelStyle: Constants.labelstyle,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: Colors.blueAccent),
                                ),
                                enabledBorder:
                                    OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black38)),
                                contentPadding: const EdgeInsets.fromLTRB(8, 3, 1, 3),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            items: [
                              "all",
                              "gga",
                              "hdt",
                              "vtg",
                            ],
                            onChanged: (value) {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    StreamBuilder<IpkapalResponse>(
                      stream: BlocProvider.of<SocketCubit>(context).IpKapalTableStreamController,
                      builder: (context, snapshot) {
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
                          print(data.data);
                          return Container(
                            width: double.infinity,
                            child: SingleChildScrollView(
                              child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(Color(0xffd3d3d3)),
                                  columns: [
                                    const DataColumn(label: SizedBox(width: 210, child: Text("IP"))),
                                    const DataColumn(label: Text("Port")),
                                    const DataColumn(label: Text("Type")),
                                    const DataColumn(label: Text("Delete")),
                                  ],
                                  rows: data.data!.map((value) {
                                    return DataRow(cells: [
                                      DataCell(Text(value.ip!)),
                                      DataCell(Text(value.port!)),
                                      DataCell(Text(value.typeIp!)),
                                      DataCell(IconButton(
                                        onPressed: () {
                                          Alerts.showAlertYesNo(
                                              title: "Are you sure you want to delete this data?",
                                              onPressYes: () {
                                                // readNotifier.deleteIP(data.idIpKapal!, data.callSign!, context);
                                                // load = true;
                                              },
                                              onPressNo: () {
                                                Navigator.pop(context);
                                              },
                                              context: context);
                                        },
                                        icon: Icon(Icons.delete),
                                      )),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
