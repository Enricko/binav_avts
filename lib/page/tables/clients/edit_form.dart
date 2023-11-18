import 'dart:async';

import 'package:binav_avts/response/websocket/client_response.dart' as ClientResponse;
import 'package:binav_avts/services/client_dataservice.dart';
import 'package:binav_avts/utils/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';

class EditClient extends StatefulWidget {
  const EditClient({super.key, required this.data});
  final ClientResponse.Data data;

  @override
  State<EditClient> createState() => _EditClientState();
}

class _EditClientState extends State<EditClient> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool isSwitched = false;
  bool ignorePointer = false;
  Timer? ignorePointerTimer;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    nameController.text = widget.data.clientName!;
    emailController.text = widget.data.email!;
    isSwitched = widget.data.status!.toLowerCase() == "1";
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    if(ignorePointerTimer != null){ignorePointerTimer!.cancel();}
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
                    " Edit Client",
                    style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isSwitched = false;
                      });
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
                      const SizedBox(
                        height: 5,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
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
                            CustomTextField(
                              controller: emailController,
                              hint: 'Email',
                              type: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.isEmpty || value == "") {
                                  return "The Email field is required.";
                                }
                                if (!RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
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
                                  // If the form is valid, display a snackbar. In the real world,
                                  // you'd often call a server or save the information in a database.
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   const SnackBar(
                                  //       content: Text('Processing Data')),
                                  // );
                                  setState(() {
                                    ignorePointer = true;
                                    ignorePointerTimer = Timer(const Duration(seconds: 3), () {
                                      setState(() {
                                        ignorePointer = false;
                                      });
                                    });
                                  });
                                  EasyLoading.show(status: "Loading...");

                                  ClientDataService()
                                      .editClient(
                                          id_client: widget.data.idClient!,
                                          client_name: nameController.text,
                                          email: emailController.text,
                                          isSwitched: isSwitched)
                                      .then((value) {
                                    if (value.status == 200) {
                                      setState(() {
                                        isSwitched = false;
                                      });
                                      EasyLoading.showSuccess(value.message!,
                                          duration: const Duration(seconds: 3), dismissOnTap: true);
                                      Navigator.pop(context);
                                    } else {
                                      EasyLoading.showError(value.message!,
                                          duration: const Duration(seconds: 3), dismissOnTap: true);
                                    }
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
            ),
          ],
        ),
      ),
    );
  }
}
