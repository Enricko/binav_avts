import 'dart:async';

import 'package:binav_avts/bloc/auth_widget/auth_widget_bloc.dart';
import 'package:binav_avts/page/screen/forgot_password/send_email_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/general/general_cubit.dart';

class CreateNewPassword extends StatefulWidget {
  const CreateNewPassword({Key? key}) : super(key: key);

  @override
  State<CreateNewPassword> createState() => _CreateNewPasswordState();
}

class _CreateNewPasswordState extends State<CreateNewPassword> {
  final _formKey = GlobalKey<FormState>();
  Timer? ignorePointerTimer;
  bool ignorePointer = false;

  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordconfirmController = TextEditingController();

  bool invisible = true;
  bool invisibleConfirm = true;

  @override
  void dispose() {
    if(ignorePointerTimer != null){ignorePointerTimer!.cancel();}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthWidgetBloc, AuthWidgetState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
                onTap: () {
                  context.read<AuthWidgetBloc>().add(EmailConfirm());
                },
                child: Icon(Icons.arrow_back)),
            SizedBox(
              height: 15,
            ),
            Text(
              "Create New Password",
              style: GoogleFonts.roboto(
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "this password should be different from the previous password",
              style: GoogleFonts.roboto(fontSize: 15, color: Colors.black38),
            ),
            SizedBox(
              height: 40,
            ),
            Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: passwordController,
                        textInputAction: TextInputAction.next,
                        obscureText: invisible,
                        validator: (value) {
                          if (value == null || value.isEmpty || value == "") {
                            return "The Password field is required.";
                          }
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20, 3, 1, 3),
                          hintText: "Enter New Password",
                          suffixIcon: IconButton(
                            icon: Icon((invisible == true) ? Icons.visibility_outlined : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                invisible = !invisible;
                              });
                            },
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: Colors.blueAccent),
                          ),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black38)),
                          errorBorder: OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.redAccent)),
                          focusedErrorBorder:
                              OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.redAccent)),
                          filled: true,
                          fillColor: Color(0x0f2f2f2f),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: passwordconfirmController,
                        textInputAction: TextInputAction.next,
                        obscureText: invisibleConfirm,
                        validator: (value) {
                          if (value == null || value.isEmpty || value == "") {
                            return "The Password Confirmation field is required.";
                          }
                          if (value != passwordController.text) {
                            return "Password does not match";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20, 3, 1, 3),
                          hintText: "Enter Confirm Password",
                          suffixIcon: IconButton(
                            icon: Icon((invisibleConfirm == true) ? Icons.visibility_outlined : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                invisibleConfirm = !invisibleConfirm;
                              });
                            },
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: Colors.blueAccent),
                          ),
                          enabledBorder:
                              const OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black38)),
                          errorBorder:
                              const OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.redAccent)),
                          focusedErrorBorder:
                              const OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.redAccent)),
                          filled: true,
                          fillColor: const Color(0x0f2f2f2f),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                IgnorePointer(
                  ignoring: ignorePointer,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 25),
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(const Color(0xFF133BAD)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            ignorePointer = true;
                            ignorePointerTimer = Timer(const Duration(seconds: 3), () {
                              setState(() {
                                ignorePointer = false;
                              });
                            });
                          });
                          EasyLoading.show(status: "Loading...");
                          context.read<AuthWidgetBloc>().add(ResetSuccess(
                              code: state is AuthResetPassword ? state.code : '',
                              password: passwordController.text,
                              password_confirmation: passwordconfirmController.text));
                        }
                      },
                      child: Text(
                        "Reset Password",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
