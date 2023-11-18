import 'dart:async';
import 'dart:typed_data';

import 'package:binav_avts/bloc/websocket/socket_cubit.dart';
import 'package:binav_avts/response/websocket/client_response.dart';
import 'package:binav_avts/services/pipeline_dataservice.dart';
import 'package:binav_avts/utils/constants.dart';
import 'package:binav_avts/utils/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import "package:dropdown_textfield/dropdown_textfield.dart";
import 'package:file_picker/file_picker.dart';
import 'package:responsive_ui/responsive_ui.dart';

class AddPipeline extends StatefulWidget {
  const AddPipeline({super.key});

  @override
  State<AddPipeline> createState() => _AddPipelineState();
}

class _AddPipelineState extends State<AddPipeline> {
  SingleValueDropDownController clientController = SingleValueDropDownController();
  String? idClientValue;
  TextEditingController nameController = TextEditingController();

  TextEditingController filePickerController = TextEditingController();
  bool isSwitched = false;
  bool ignorePointer = false;
  Timer? _timer;
  Timer? ignorePointerTimer;

  final _formKey = GlobalKey<FormState>();

  Uint8List? filePickerVal;

  selectFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['kml', 'kmz']);
    if (result != null) {
      setState(() {
        filePickerController.text = result.files.single.name;
        filePickerVal = result.files.first.bytes;
        // filePickerVal!.path;
      });
    } else {
      // User canceled the picker
    }
  }

  @override
  void initState() {
    BlocProvider.of<SocketCubit>(context).getClientDataTable(payload: {
      // "id_client": widget.idClient,
      "page": 1,
      "perpage": 100
    });
    _timer = Timer.periodic(const Duration(milliseconds: 5000), (timer) {
      BlocProvider.of<SocketCubit>(context).getClientDataTable(payload: {
        // "id_client": widget.idClient,
        "page": 1,
        "perpage": 100
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    clientController.dispose();
    filePickerController.dispose();
    _timer!.cancel();
    if(ignorePointerTimer != null){ignorePointerTimer!.cancel();}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Container(
        width: width <= 540 ? width / 1.3 : width / 1.6,
        margin: const EdgeInsets.symmetric(horizontal: 8),
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
                    " Add Pipeline",
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
            Padding(
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: StreamBuilder<ClientResponse>(
                                stream: BlocProvider.of<SocketCubit>(context).ClientTableStreamController,
                                builder: (context, snapshot) {
                                  return DropDownTextField(
                                    controller: clientController,
                                    dropDownList: [
                                      if (snapshot.hasData)
                                        for (var x in snapshot.data!.data!)
                                          DropDownValueModel(
                                              name: '${x.clientName} - ${x.idClient}', value: "${x.idClient}"),
                                    ],
                                    clearOption: false,
                                    enableSearch: true,
                                    textStyle: const TextStyle(color: Colors.black),
                                    searchDecoration:
                                        const InputDecoration(hintText: "enter your custom hint text here"),
                                    validator: (value) {
                                      if (value == null || value == "" || value.isEmpty) {
                                        return "Required field";
                                      } else {
                                        return null;
                                      }
                                    },
                                    onChanged: (value) {
                                      idClientValue = clientController.dropDownValue!.value.toString();
                                    },
                                    textFieldDecoration: InputDecoration(
                                      labelText: "Pilih Client",
                                      labelStyle: Constants.labelstyle,
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(width: 1, color: Colors.blueAccent),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(width: 1, color: Colors.black38)),
                                      errorBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(width: 1, color: Colors.redAccent)),
                                      focusedErrorBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(width: 1, color: Colors.redAccent)),
                                      contentPadding: const EdgeInsets.fromLTRB(8, 3, 1, 3),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                  );
                                }),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextField(
                            controller: nameController,
                            hint: 'Name',
                            type: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty || value == "") {
                                return "The Name field is required.";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Responsive(
                            children: [
                              Div(
                                divison: const Division(
                                  colS: 9,
                                  colM: 9,
                                  colL: 9,
                                  colXL: 9,
                                ),
                                child: CustomTextField(
                                  readOnly: true,
                                  controller: filePickerController,
                                  hint: 'File Name',
                                  type: TextInputType.text,
                                  validator: (value) {
                                    if (value == null || value.isEmpty || value == "") {
                                      return "The File field is required.";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Div(
                                divison: const Division(
                                  colS: 3,
                                  colM: 3,
                                  colL: 3,
                                  colXL: 3,
                                ),
                                child: ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.upload_file,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                  label: const Text('Pilih File', style: TextStyle(fontSize: 16.0)),
                                  onPressed: () {
                                    selectFile();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue,
                                    minimumSize: const Size(122, 48),
                                    maximumSize: const Size(122, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Column(
                      children: [
                        const Text("Off/On"),
                        SizedBox(
                          height: 40,
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Switch(
                              value: isSwitched,
                              onChanged: (bool value) {
                                setState(() {
                                  isSwitched = value;
                                });
                              },
                              activeTrackColor: Colors.lightGreen,
                              activeColor: Colors.green,
                            ),
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
                              if (_formKey.currentState!.validate()) {
                                // Prevent Multiple Clicked
                                setState(() {
                                  ignorePointer = true;
                                  ignorePointerTimer = Timer(const Duration(seconds: 3), () {
                                    setState(() {
                                      ignorePointer = false;
                                    });
                                  });
                                });
                                EasyLoading.show(status: "Loading...");

                                PipelineDataService()
                                    .addPipeline(
                                        id_client: idClientValue!,
                                        name: nameController.text,
                                        file: filePickerVal!,
                                        fileName: filePickerController.text,
                                        isSwitched: isSwitched)
                                    .then((value) {
                                  if (value.status == 200) {
                                    EasyLoading.showSuccess(value.message!,
                                        duration: const Duration(seconds: 3), dismissOnTap: true);
                                    Navigator.pop(context);
                                  } else {
                                    EasyLoading.showError(value.message!,
                                        duration: const Duration(seconds: 3), dismissOnTap: true);
                                  }
                                }).whenComplete(() {
                                  Timer(const Duration(seconds: 5), () {
                                    EasyLoading.dismiss();
                                  });
                                });
                              }
                            },
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        TextButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: const BorderSide(color: Colors.blueAccent)))),
                          onPressed: () {
                            setState(() {
                              isSwitched = false;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
