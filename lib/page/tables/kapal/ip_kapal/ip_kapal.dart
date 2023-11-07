import 'dart:async';

import 'package:binav_avts/bloc/websocket/socket_cubit.dart';
import 'package:binav_avts/response/websocket/ipkapal_response.dart';
import 'package:binav_avts/services/kapal/ip_kapal_dataservice.dart';
import 'package:binav_avts/utils/alerts.dart';
import 'package:binav_avts/utils/constants.dart';
import 'package:binav_avts/utils/text_field.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool ignorePointer = false;
  Timer? _timer;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      BlocProvider.of<SocketCubit>(context)
          .getIPKapalDataTable(payload: {"call_sign": widget.callSign, "page": 1, "perpage": 10});
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
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          CustomTextField(
                            controller: ipController,
                            hint: 'IP',
                            type: TextInputType.text,
                            inputFormatters: [
                              MyInputFormatters.ipAddressInputFilter(),
                              LengthLimitingTextInputFormatter(15),
                              IpAddressInputFormatter()
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty || value == "") {
                                return "The IP field is required.";
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  child: TextFormField(
                                    style: TextStyle(fontSize: 14),
                                    controller: portController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(5),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty || value == "") {
                                        return "The Port field is required.";
                                      }
                                      return null;
                                    },
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
                                        errorBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(width: 1, color: Colors.redAccent)),
                                        focusedErrorBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(width: 1, color: Colors.redAccent)),
                                        filled: true,
                                        fillColor: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              SizedBox(
                                width: 150,
                                child: DropdownSearch<String>(
                                  selectedItem: type,
                                  dropdownBuilder: (context, selectedItem) => Text(
                                    selectedItem ?? "",
                                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty || value == "") {
                                      return "The Type field is required.";
                                    }
                                    return null;
                                  },
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
                                      errorBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(width: 1, color: Colors.redAccent)),
                                      focusedErrorBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(width: 1, color: Colors.redAccent)),
                                      contentPadding: const EdgeInsets.fromLTRB(8, 3, 1, 3),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                  ),
                                  items: const [
                                    "all",
                                    "gga",
                                    "hdt",
                                    "vtg",
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      type = value;
                                    });
                                  },
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
                              IgnorePointer(
                                ignoring: ignorePointer,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    try {
                                      if (_formKey.currentState!.validate()) {
                                        // Prevent Multiple Clicked
                                        setState(() {
                                          ignorePointer = true;
                                          Timer(Duration(seconds: 3), () {
                                            ignorePointer = false;
                                          });
                                        });
                                        EasyLoading.show(status: "Loading...");
                                        IpKapalDataService()
                                            .addIpKapal(
                                                callSign: widget.callSign,
                                                ip: ipController.text,
                                                port: portController.text,
                                                type: type!)
                                            .then((value) {
                                          if (value.status == 200) {
                                            EasyLoading.showSuccess(value.message!,
                                                duration: Duration(seconds: 3), dismissOnTap: true);
                                          } else {
                                            EasyLoading.showError(value.message!,
                                                duration: Duration(seconds: 3), dismissOnTap: true);
                                          }
                                        }).whenComplete(() {
                                          ipController.clear();
                                          portController.clear();
                                          type = null;
                                          Timer(Duration(seconds: 5), () {
                                            EasyLoading.dismiss();
                                          });
                                        });
                                      }
                                    } catch (e) {
                                      print("adads $e");
                                      EasyLoading.showError(e.toString());
                                    }
                                  },
                                  child: Text(
                                    "Save",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ),
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
                              child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(Color(0xffd3d3d3)),
                                  columns: const [
                                    DataColumn(label: SizedBox(width: 210, child: Text("IP"))),
                                    DataColumn(label: Text("Port")),
                                    DataColumn(label: Text("Type")),
                                    DataColumn(label: Text("Delete")),
                                  ],
                                  rows: data.data!.map((value) {
                                    return DataRow(cells: [
                                      DataCell(Text(value.ip!)),
                                      DataCell(Text(value.port!)),
                                      DataCell(Text(value.typeIp!)),
                                      DataCell(Tooltip(
                                        message: "Delete",
                                        child: IconButton(
                                          onPressed: () {
                                            Alerts.showAlertYesNo(
                                                title: "Are you sure you want to delete this data?",
                                                onPressYes: () async {
                                                  if (!ignorePointer) {
                                                      setState(() {
                                                        ignorePointer = true;
                                                        Timer(const Duration(seconds: 3), () {
                                                          ignorePointer = false;
                                                        });
                                                      });
                                                      EasyLoading.show(status: "Loading...");
                                                      try {
                                                        SharedPreferences pref = await SharedPreferences.getInstance();
                                                        IpKapalDataService()
                                                            .deleteIpKapal(
                                                                token: pref.getString("token")!,
                                                                idIpKapal: value.idIpKapal.toString())
                                                            .then((val) {
                                                          if (val.status == 200) {
                                                            EasyLoading.showSuccess(val.message!,
                                                                duration: const Duration(seconds: 3), dismissOnTap: true);
                                                            Navigator.pop(context);
                                                          } else {
                                                            EasyLoading.showError(val.message!,
                                                                duration: const Duration(seconds: 3), dismissOnTap: true);
                                                            Navigator.pop(context);
                                                          }
                                                        });
                                                      } catch (e) {
                                                        print(e);
                                                        EasyLoading.showError(e.toString());
                                                      }
                                                    }
                                                },
                                                onPressNo: () {
                                                  Navigator.pop(context);
                                                },
                                                context: context);
                                          },
                                          icon: Icon(Icons.delete,color:Colors.redAccent),
                                        ),
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

class MyInputFormatters {
  static TextInputFormatter ipAddressInputFilter() {
    return FilteringTextInputFormatter.allow(RegExp("[0-9.]"));
  }
}

class IpAddressInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    int dotCounter = 0;
    var buffer = StringBuffer();
    String ipField = "";

    for (int i = 0; i < text.length; i++) {
      if (dotCounter < 4) {
        if (text[i] != ".") {
          ipField += text[i];
          if (ipField.length < 3) {
            buffer.write(text[i]);
          } else if (ipField.length == 3) {
            if (int.parse(ipField) <= 255) {
              buffer.write(text[i]);
            } else {
              if (dotCounter < 3) {
                buffer.write(".");
                dotCounter++;
                buffer.write(text[i]);
                ipField = text[i];
              }
            }
          } else if (ipField.length == 4) {
            if (dotCounter < 3) {
              buffer.write(".");
              dotCounter++;
              buffer.write(text[i]);
              ipField = text[i];
            }
          }
        } else {
          if (dotCounter < 3) {
            buffer.write(".");
            dotCounter++;
            ipField = "";
          }
        }
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}
