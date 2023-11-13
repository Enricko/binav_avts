import 'dart:async';

import 'package:binav_avts/bloc/websocket/socket_cubit.dart';
import 'package:binav_avts/page/tables/kapal/add_form.dart';
import 'package:binav_avts/page/tables/kapal/detail_kapal.dart';
import 'package:binav_avts/page/tables/kapal/edit_form.dart';
import 'package:binav_avts/page/tables/kapal/ip_kapal/ip_kapal.dart';
import 'package:binav_avts/response/websocket/kapal_response.dart';
import 'package:binav_avts/services/kapal/kapal_dataservice.dart';
import 'package:binav_avts/utils/alerts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KapalTablePage extends StatefulWidget {
  const KapalTablePage({super.key, this.idClient = ""});
  final String idClient;

  @override
  State<KapalTablePage> createState() => _KapalTablePageState();
}

class _KapalTablePageState extends State<KapalTablePage> {
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
      BlocProvider.of<SocketCubit>(context)
          .getKapalDataTable(payload: {"id_client": widget.idClient, "page": page, "perpage": perpage});
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
                  " Vessel List",
                  style: GoogleFonts.openSans(fontSize: 20, fontWeight: FontWeight.bold),
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
                Text("Page $page of ${totalPage == null ? "?" : (totalPage! / perpage).ceil()}"),
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
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                              backgroundColor: MaterialStateProperty.all(Colors.blueAccent)),
                          onPressed: () {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const Dialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                    child: AddKapal(),
                                  );
                                });
                          },
                          child: const Text(
                            "Add Vessel",
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
          StreamBuilder<KapalResponse>(
            stream: BlocProvider.of<SocketCubit>(context).KapalTableStreamController,
            builder: (context, AsyncSnapshot<KapalResponse> snapshot) {
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
                KapalResponse data = snapshot.data!;
                totalPage = data.total;
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: load
                          ? const Center(child: CircularProgressIndicator())
                          : DataTable(
                              headingRowColor: MaterialStateProperty.all(const Color(0xffd3d3d3)),
                              columns: const [
                                DataColumn(label: Text("CallSign")),
                                DataColumn(label: Text("Flag")),
                                DataColumn(label: Text("Class")),
                                DataColumn(label: Text("Builder")),
                                DataColumn(label: Text("Year Built")),
                                DataColumn(label: Text("Size")),
                                DataColumn(label: Text("File XML")),
                                DataColumn(label: Text("Upload IP ")),
                                DataColumn(label: Text("Action")),
                              ],
                              rows: data.data!.map((value) {
                                return DataRow(cells: [
                                  DataCell(Text(value.callSign!)),
                                  DataCell(Text(value.flag!)),
                                  DataCell(Text(value.kelas!)),
                                  DataCell(Text(value.builder!)),
                                  DataCell(Text(value.yearBuilt!)),
                                  DataCell(Text(value.size!)),
                                  DataCell(SizedBox(
                                    width: 150,
                                    child: Text(
                                      value.xmlFile!.replaceAll("https://api.binav-avts.id/storage/xml/", ""),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  )),
                                  DataCell(Tooltip(
                                    message: "Ip Kapal",
                                    child: IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: IpKapalPage(callSign: value.callSign!),
                                                );
                                              });
                                        },
                                        icon: const Icon(Icons.edit_location_alt_outlined)),
                                  )),
                                  DataCell(Row(
                                    children: [
                                      Tooltip(
                                        message: "View Detail",
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.visibility,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(5))),
                                                    child: DetailKapal(data: value),
                                                  );
                                                });
                                          },
                                        ),
                                      ),
                                      Tooltip(
                                        message: "Edit",
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(5))),
                                                    child: EditKapal(data: value),
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
                                                      KapalDataService()
                                                          .deleteKapal(
                                                              token: pref.getString("token")!,
                                                              call_sign: value.callSign.toString())
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
                                        ),
                                      ),
                                    ],
                                  )),
                                ]);
                              }).toList())),
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
