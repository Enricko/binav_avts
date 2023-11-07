import 'dart:async';

import 'package:binav_avts/bloc/websocket/socket_cubit.dart';
import 'package:binav_avts/page/tables/clients/add_form.dart';
import 'package:binav_avts/page/tables/clients/edit_form.dart';
import 'package:binav_avts/response/websocket/client_response.dart';
import 'package:binav_avts/services/client_dataservice.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:binav_avts/utils/alerts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientTablePage extends StatefulWidget {
  const ClientTablePage({super.key, this.idClient = ""});
  final String idClient;

  @override
  State<ClientTablePage> createState() => _ClientTablePageState();
}

class _ClientTablePageState extends State<ClientTablePage> {
  int page = 1;
  int perpage = 10;
  int? totalPage;

  Timer? _timer;
  bool isSwitched = false;
  bool ignorePointer = false;
  bool load = false;

  incrementPage(int pageIndex) {
    setState(() {
      page = pageIndex;
      load = true;
    });
  }

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      BlocProvider.of<SocketCubit>(context).getClientDataTable(payload: {
        "id_client": widget.idClient,
        "page": page,
        "perpage": perpage
      });
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
      width: width <= 540 ? width / 1.2 : width / 1.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.black12,
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Client List",
                  style: GoogleFonts.openSans(
                      fontSize: 20, fontWeight: FontWeight.bold),
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
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Page $page of ${totalPage == null ? "?" : (totalPage! / perpage).ceil()}"),
                Row(
                  children: [
                    const SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5))),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blueAccent)),
                          onPressed: () {
                            ///FUNCTION ADD CLIENT
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const Dialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5))),
                                      child: AddClient());
                                });
                          },
                          child: const Text(
                            "Add Client",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          )),
                    ),
                  ],
                )
              ],
            ),
          ),

          // TODO : Might need Expanded Widget
          StreamBuilder<ClientResponse>(
            stream: BlocProvider.of<SocketCubit>(context)
                .ClientTableStreamController,
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
                ClientResponse data = snapshot.data!;
                totalPage = data.total;
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                              const Color(0xffd3d3d3)),
                          columns: const [
                            DataColumn(label: Text("Name")),
                            DataColumn(label: Text("Email")),
                            DataColumn(label: Text("Status")),
                            DataColumn(label: Text("Send Email")),
                            DataColumn(
                                label: Text("View Client Only Data")),
                            DataColumn(label: Text("Action")),
                          ],
                          rows: data.data!.map((value) {
                            return DataRow(cells: [
                              DataCell(Text(value.clientName!)),
                              DataCell(Text(value.email!)),
                              DataCell(Text((value.status! == "1")
                                  ? "ACTIVE"
                                  : "INACTIVE")),
                              DataCell(ElevatedButton(
                                onPressed: () {
                                  Alerts.showAlertYesNoConfirm(
                                      title:
                                          "Are you sure you want to send mail to ${value.email}?",
                                      onPressYes: () async {
                                        if (!ignorePointer) {
                                          setState(() {
                                            ignorePointer = true;
                                            Timer(const Duration(seconds: 3), () {
                                              ignorePointer = false;
                                            });
                                          });
                                          try {
                                            EasyLoading.show(
                                                status: "Loading...");

                                            SharedPreferences pref =
                                                await SharedPreferences
                                                    .getInstance();
                                            ClientDataService()
                                                .sendMailToClient(
                                                    token: pref
                                                        .getString("token")!,
                                                    id_client: value.idClient!)
                                                .then((val) {
                                              if (val.status == 200) {
                                                EasyLoading.showSuccess(
                                                    "Successfully sent the mail to ${value.email}!",
                                                    duration:
                                                        const Duration(seconds: 3),
                                                    dismissOnTap: true);
                                                Navigator.pop(context);
                                              } else {
                                                EasyLoading.showError(
                                                    val.message!,
                                                    duration:
                                                        const Duration(seconds: 3),
                                                    dismissOnTap: true);
                                                Navigator.pop(context);
                                              }
                                            });
                                          } catch (e) {
                                            EasyLoading.showError(e.toString(),
                                                duration: const Duration(seconds: 3),
                                                dismissOnTap: true);
                                          }
                                        }
                                      },
                                      onPressNo: () {
                                        Navigator.pop(context);
                                      },
                                      context: context);
                                },
                                child: const Text("Send Email"),
                              )),
                              // DataCell(Switch(
                              //   value: isSwitched,
                              //   onChanged: (bool value) {
                              //     setState(() {
                              //       isSwitched = value;
                              //     });
                              //   },
                              //   activeTrackColor: Colors.lightGreen,
                              //   activeColor: Colors.green,
                              // )),
                              DataCell(
                                SizedBox(
                                  height: 40,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5))),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.blueAccent)),
                                      onPressed: () {
                                        ///FUNCTION VIEW CLIENT ONLY DATA
                                      },
                                      child: const Text(
                                        "View Client",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      )),
                                ),
                              ),
                              DataCell(Row(
                                children: [
                                  Tooltip(
                                    message:"Edit",
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        /// FUNCTION EDIT CLIENT
                                        // editClientList(data, context);
                                        showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    5))),
                                                child: EditClient(data: value),
                                              );
                                            });
                                      },
                                    ),
                                  ),
                                  Tooltip(
                                    message: "Delete",
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        Alerts.showAlertYesNo(
                                            title:
                                                "Are you sure you want to delete this client?",
                                            onPressYes: () async {
                                              if (!ignorePointer) {
                                                try {
                                                  setState(() {
                                                    ignorePointer = true;
                                                    Timer(const Duration(seconds: 3),
                                                        () {
                                                      ignorePointer = false;
                                                    });
                                                  });
                                                  EasyLoading.show(
                                                      status: "Loading...");
                                  
                                                  SharedPreferences pref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  ClientDataService()
                                                      .deleteClient(
                                                          token: pref.getString(
                                                              "token")!,
                                                          id_client:
                                                              value.idClient!)
                                                      .then((value) {
                                                    if (value.status == 200) {
                                                      EasyLoading.showSuccess(
                                                          value.message!,
                                                          duration: const Duration(
                                                              seconds: 3),
                                                          dismissOnTap: true);
                                                      Navigator.pop(context);
                                                    } else {
                                                      EasyLoading.showError(
                                                          value.message!,
                                                          duration: const Duration(
                                                              seconds: 3),
                                                          dismissOnTap: true);
                                                      Navigator.pop(context);
                                                    }
                                                  });
                                                } catch (e) {
                                                  EasyLoading.showError(
                                                      e.toString(),
                                                      duration:
                                                          const Duration(seconds: 3),
                                                      dismissOnTap: true);
                                                }
                                              }
                                            },
                                            onPressNo: () {
                                              Navigator.pop(context);
                                            },
                                            context: context);
                                      },
                                    ),
                                  ),
                                ],
                              )),
                            ]);
                          }).toList()),
                    ),
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
          Container(
            height: 50,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Pagination(
              numOfPages: ((totalPage ?? 0) / perpage).ceil(),
              selectedPage: page,
              pagesVisible: 7,
              onPageChanged: (value) {
                if (value != page) {
                  incrementPage(value);
                }
              },
              nextIcon: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.blue,
                size: 14,
              ),
              previousIcon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.blue,
                size: 14,
              ),
              activeTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              activeBtnStyle: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(38),
                  ),
                ),
              ),
              inactiveBtnStyle: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(38),
                )),
              ),
              inactiveTextStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
