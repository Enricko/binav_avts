import 'dart:async';

import 'package:binav_avts/services/client_dataservice.dart';
import 'package:binav_avts/utils/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';

class AddClient extends StatefulWidget {
  const AddClient({super.key});

  @override
  State<AddClient> createState() => _AddClientState();
}

class _AddClientState extends State<AddClient> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isSwitched = false;
  bool ignorePointer = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
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
                    " Add Client",
                    style: GoogleFonts.openSans(
                        fontSize: 15, fontWeight: FontWeight.bold),
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
              padding: const EdgeInsets.all(12),
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
                              if (value == null ||
                                  value.isEmpty ||
                                  value == "") {
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
                              if (value == null ||
                                  value.isEmpty ||
                                  value == "") {
                                return "The Email field is required.";
                              }
                              if (!RegExp(
                                      r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            controller: passwordController,
                            hint: 'Password',
                            type: TextInputType.text,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value == "") {
                                return "The Password field is required.";
                              } else if (passwordController.text !=
                                  confirmPasswordController.text) {
                                return "Password & Confirmation Password not match.";
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            controller: confirmPasswordController,
                            hint: 'Confirm Password',
                            type: TextInputType.text,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value == "") {
                                return "The Confirm Password field is required.";
                              } else if (passwordController.text !=
                                  confirmPasswordController.text) {
                                return "Password & Confirmation Password not match.";
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
                    const Text(
                      "Status",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blueAccent),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  ignorePointer = true;
                                  Timer(Duration(seconds: 3), () {
                                    ignorePointer = false;
                                  });
                                });
                                EasyLoading.show(status: "Loading...");
                                ClientDataService()
                                    .addClient(
                                        client_name: nameController.text,
                                        email: emailController.text,
                                        password: passwordController.text,
                                        password_confirmation:
                                            passwordController.text,
                                        isSwitched: isSwitched)
                                    .then((value) {
                                  if (value.status == 200) {
                                    setState(() {
                                      isSwitched = false;
                                    });
                                    EasyLoading.showSuccess(value.message!,
                                        duration: Duration(seconds: 3),
                                        dismissOnTap: true);
                                    Navigator.pop(context);
                                  } else {
                                    EasyLoading.showError(value.message!,
                                        duration: Duration(seconds: 3),
                                        dismissOnTap: true);
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
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      side: const BorderSide(
                                          color: Colors.blueAccent)))),
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
