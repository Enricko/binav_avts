import 'dart:async';
import 'dart:typed_data';

import 'package:binav_avts/response/websocket/mapping_response.dart' as MappingResponse;
import 'package:binav_avts/services/pipeline_dataservice.dart';
import 'package:binav_avts/utils/text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_ui/responsive_ui.dart';

class EditPipeline extends StatefulWidget {
  const EditPipeline({super.key, required this.data});
  final MappingResponse.Data data;

  @override
  State<EditPipeline> createState() => _EditPipelineState();
}

class _EditPipelineState extends State<EditPipeline> {
  // SingleValueDropDownController clientController =
  //     SingleValueDropDownController();
  // String? idClientValue;
  TextEditingController nameController = TextEditingController();
  TextEditingController FilePickerController = TextEditingController();
  bool isSwitched = false;
  bool ignorePointer = false;
  // Timer? _timer;

  final _formKey = GlobalKey<FormState>();

  Uint8List? filePickerVal;

  selectFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['kml', 'kmz']);
    if (result != null) {
      setState(() {
        FilePickerController.text = result.files.single.name;
        filePickerVal = result.files.first.bytes;
        // filePickerVal!.path;
      });
    } else {
      // User canceled the picker
    }
  }

  @override
  void initState() {
    setState(() {
      nameController.text = widget.data.name!;
      FilePickerController.text = widget.data.file!;
      isSwitched = widget.data.onOff!;
    });
    // BlocProvider.of<SocketCubit>(context).getClientDataTable(payload: {
    //   // "id_client": widget.idClient,
    //   "page": 1,
    //   "perpage": 100
    // });
    // _timer = Timer.periodic(const Duration(milliseconds: 5000), (timer) {
    //   BlocProvider.of<SocketCubit>(context).getClientDataTable(payload: {
    //     // "id_client": widget.idClient,
    //     "page": 1,
    //     "perpage": 100
    //   });
    // });
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    FilePickerController.dispose();
    // _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: SizedBox(
        width: width <= 540 ? width / 1.3 : width / 1.6,
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
                    " Edit Pipeline",
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
                                divison: Division(
                                  colS: 9,
                                  colM: 9,
                                  colL: 9,
                                  colXL: 9,
                                ),
                                child: CustomTextField(
                                  readOnly: true,
                                  controller: FilePickerController,
                                  hint: 'File Name',
                                  type: TextInputType.text,
                                  validator: (value) {
                                    return null;
                                  },
                                ),
                              ),
                              Div(
                                divison: Division(
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
                                    primary: Colors.lightBlue,
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
                                try {
                                  // Prevent Multiple Clicked
                                  setState(() {
                                    ignorePointer = true;
                                    Timer(Duration(seconds: 3), () {
                                      ignorePointer = false;
                                    });
                                  });
                                  EasyLoading.show(status: "Loading...");

                                  if (filePickerVal != null) {
                                    PipelineDataService()
                                        .editPipeline(
                                            id_mapping: widget.data.idMapping.toString(),
                                            name: nameController.text,
                                            isSwitched: isSwitched,
                                            fileName: FilePickerController.text,
                                            file: filePickerVal!)
                                        .then((value) {
                                      if (value.status == 200) {
                                        EasyLoading.showSuccess(value.message!,
                                            duration: Duration(seconds: 3), dismissOnTap: true);
                                        Navigator.pop(context);
                                      } else {
                                        EasyLoading.showError(value.message!,
                                            duration: Duration(seconds: 3), dismissOnTap: true);
                                      }
                                    }).whenComplete(() {
                                      Timer(Duration(seconds: 5), () {
                                        EasyLoading.dismiss();
                                      });
                                    });
                                  } else {
                                    PipelineDataService()
                                        .editPipelineNoFile(
                                            id_mapping: widget.data.idMapping.toString(),
                                            name: nameController.text,
                                            isSwitched: isSwitched)
                                        .then((value) {
                                      if (value.status == 200) {
                                        EasyLoading.showSuccess(value.message!,
                                            duration: Duration(seconds: 3), dismissOnTap: true);
                                        Navigator.pop(context);
                                      } else {
                                        EasyLoading.showError(value.message!,
                                            duration: Duration(seconds: 3), dismissOnTap: true);
                                      }
                                    }).whenComplete(() {
                                      Timer(Duration(seconds: 5), () {
                                        EasyLoading.dismiss();
                                      });
                                    });
                                  }
                                } catch (e) {
                                  print("adads $e");
                                  EasyLoading.showError(e.toString());
                                }
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
