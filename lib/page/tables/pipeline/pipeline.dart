import 'dart:async';

import 'package:binav_avts/bloc/websocket/socket_cubit.dart';
import 'package:binav_avts/page/tables/pipeline/add_form.dart';
import 'package:binav_avts/page/tables/pipeline/edit_form.dart';
import 'package:binav_avts/response/websocket/mapping_response.dart';
import 'package:binav_avts/services/pipeline_dataservice.dart';
import 'package:binav_avts/utils/alerts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PipelineTablePage extends StatefulWidget {
  const PipelineTablePage({super.key, this.idClient = ""});
  final String idClient;

  @override
  State<PipelineTablePage> createState() => _PipelineTablePageState();
}

class _PipelineTablePageState extends State<PipelineTablePage> {
  int page = 1;
  int perpage = 10;
  int? totalPage;

  Timer? _timer;
  bool isSwitched = false;
  bool load = false;
  bool ignorePointer = false;

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
          .getMappingDataTable(payload: {"id_client": widget.idClient, "page": page, "perpage": perpage});
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
                  "Pipeline List",
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
                            ///FUNCTION ADD CLIENT
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const Dialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                    child: AddPipeline(),
                                  );
                                });
                          },
                          child: const Text(
                            "Add Pipeline",
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
          StreamBuilder<MappingResponse>(
            stream: BlocProvider.of<SocketCubit>(context).MappingTableStreamController,
            builder: (context, AsyncSnapshot<MappingResponse> snapshot) {
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
                MappingResponse data = snapshot.data!;
                totalPage = data.total;
                return Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: SingleChildScrollView(
                      child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                              headingRowColor: MaterialStateProperty.all(const Color(0xffd3d3d3)),
                              columns: const [
                                DataColumn(label: Text("Name")),
                                DataColumn(label: Text("File")),
                                DataColumn(label: Text("Switch")),
                                DataColumn(label: Text("Action")),
                              ],
                              rows: data.data!.map((value) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(value.name!)),
                                    DataCell(
                                        Text(value.file!.replaceAll("https://api.binav-avts.id/storage/mapping/", ""))),
                                    DataCell(Text(value.onOff! ? "ON" : "OFF")),
                                    DataCell(Row(
                                      children: [
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
                                                      child: EditPipeline(data: value),
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
                                                      PipelineDataService()
                                                          .deletePipeline(
                                                              token: pref.getString("token")!,
                                                              id_mapping: value.idMapping.toString())
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
                                                context: context,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    )),
                                  ],
                                );
                              }).toList())),
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
