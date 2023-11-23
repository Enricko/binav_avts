import 'dart:async';

import 'package:binav_avts/bloc/auth_widget/auth_widget_bloc.dart';
import 'package:binav_avts/page/screen/forgot_password/send_otp.dart';
import 'package:binav_avts/page/screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/general/general_cubit.dart';
import '../../../services/user_dataservice.dart';

class SendEmailConfirm extends StatefulWidget {
  const SendEmailConfirm({Key? key}) : super(key: key);

  @override
  State<SendEmailConfirm> createState() => _SendEmailConfirmState();
}

class _SendEmailConfirmState extends State<SendEmailConfirm> {
  TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Timer? ignorePointerTimer;
  bool ignorePointer = false;
  
  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    if(ignorePointerTimer != null){ignorePointerTimer!.cancel();}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
            onTap: () {
              context.read<AuthWidgetBloc>().add(Login());
            },
            child: Icon(Icons.arrow_back)),
        SizedBox(
          height: 15,
        ),
        Image.asset(
          "assets/logo.png",
          height: 40,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "Forgot your Password ?",
          style: GoogleFonts.roboto(
            fontSize: 20,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "Enter your email below, and we'll send an email with confirmation to reset your password",
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
                    controller: emailController,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty || value == "") {
                        return "The Email field is required.";
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(5),
                      hintText: "Email",
                      prefixIcon: const Icon(Icons.email),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.blueAccent),
                      ),
                      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black38)),
                      errorBorder: const OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.redAccent)),
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
                      // Prevent Multiple Clicked
                      setState(() {
                        ignorePointer = true;
                        ignorePointerTimer = Timer(const Duration(seconds: 3), () {
                          setState(() {
                            ignorePointer = false;
                          });
                        });
                        context.read<AuthWidgetBloc>().add(OtpConfirm(email: emailController.text));
                      });
                    }
                  },
                  child: const Text(
                    "Send Code",
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
  }
}
