import 'dart:async';
import 'dart:typed_data';

import 'package:binav_avts/response/websocket/kapal_response.dart' as KapalResponse;
import 'package:binav_avts/services/kapal/kapal_dataservice.dart';
import 'package:binav_avts/utils/constants.dart';
import 'package:binav_avts/utils/text_field.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_ui/responsive_ui.dart';

class EditKapal extends StatefulWidget {
  const EditKapal({super.key, required this.data});
  final KapalResponse.Data data;

  @override
  State<EditKapal> createState() => _EditKapalState();
}

class _EditKapalState extends State<EditKapal> {
  // SingleValueDropDownController clientController = SingleValueDropDownController();
  // String? idClientValue;
  TextEditingController callsignController = TextEditingController();
  TextEditingController flagController = TextEditingController();
  TextEditingController classController = TextEditingController();
  TextEditingController builderController = TextEditingController();
  TextEditingController yearbuiltController = TextEditingController();
  TextEditingController FilePickerController = TextEditingController();
  String? vesselSize;
  bool isSwitched = false;
  bool ignorePointer = false;
  Timer? ignorePointerTimer;

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
    callsignController.text = widget.data.callSign!;
    flagController.text = widget.data.flag!;
    classController.text = widget.data.kelas!;
    builderController.text = widget.data.builder!;
    yearbuiltController.text = widget.data.yearBuilt!;
    FilePickerController.text = widget.data.xmlFile!;
    vesselSize = widget.data.size;
    super.initState();
  }

  @override
  void dispose() {
    // clientController.dispose();
    callsignController.dispose();
    flagController.dispose();
    classController.dispose();
    builderController.dispose();
    yearbuiltController.dispose();
    FilePickerController.dispose();
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
                    " Edit Vessel",
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
              height: 485,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTextField(
                              controller: callsignController,
                              hint: 'Call Sign',
                              type: TextInputType.text,
                            ),
                            CustomTextField(
                              controller: flagController,
                              hint: 'Bendera',
                              type: TextInputType.text,
                            ),
                            CustomTextField(
                              controller: classController,
                              hint: 'Kelas',
                              type: TextInputType.text,
                            ),
                            CustomTextField(
                              controller: builderController,
                              hint: 'Builder',
                              type: TextInputType.text,
                            ),
                            CustomTextField(
                              controller: yearbuiltController,
                              hint: 'Tahun Pembuatan',
                              type: TextInputType.number,
                            ),
                            SizedBox(
                              height: 35,
                              width: double.infinity,
                              child: DropdownSearch<String>(
                                dropdownBuilder: (context, selectedItem) => Text(
                                  selectedItem ?? "",
                                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty || value == "") {
                                    return "The Ukuran Kapal field is required.";
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
                                    labelText: "Ukuran Kapal",
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

                                  ///
                                ),
                                items: [
                                  "small",
                                  "medium",
                                  "large",
                                ],
                                onChanged: (value) {
                                  vesselSize = value;
                                },
                              ),
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
                                    controller: FilePickerController,
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
                                    label: const Text('Pilih File KML / KMZ File Only', style: TextStyle(fontSize: 16.0)),
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
                          ],
                        ),
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
                                      ignorePointerTimer = Timer(const Duration(seconds: 3), () {
                                        setState(() {
                                          ignorePointer = false;
                                        });
                                      });
                                    });
                                    EasyLoading.show(status: "Loading...");

                                    var data = {
                                      "old_call_sign": widget.data.callSign,
                                      "call_sign": callsignController.text,
                                      "flag": flagController.text,
                                      "class": classController.text,
                                      "builder": builderController.text,
                                      "year_built": yearbuiltController.text,
                                      "size": vesselSize
                                    };

                                    if (filePickerVal != null) {
                                      KapalDataService()
                                          .editKapal(
                                              isSwitched: isSwitched,
                                              fileName: FilePickerController.text,
                                              file: filePickerVal!,
                                              data: data)
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
                                    } else {
                                      KapalDataService()
                                          .editKapalNoFile(isSwitched: isSwitched, data: data)
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
            ),
          ],
        ),
      ),
    );
  }
}
