import 'dart:async';

import 'package:binav_avts/page/screen/forgot_password/create_new_password.dart';
import 'package:binav_avts/page/screen/forgot_password/send_email_confirmation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../bloc/general/general_cubit.dart';
import '../../../services/user_dataservice.dart';

class SendOtp extends StatefulWidget {
  final String email;
  const SendOtp({Key? key, required this.email}) : super(key: key);

  @override
  State<SendOtp> createState() => _SendOtpState();
}

class _SendOtpState extends State<SendOtp> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController otpController = TextEditingController();
  bool ignorePointer = false;

  ///
  late Timer countdownTimer;
  int resendTime = 60;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    countdownTimer.cancel();
    super.dispose();
  }

  startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        resendTime = resendTime - 1;
      });
      if (resendTime < 1) {
        countdownTimer.cancel();
      }
    });
  }

  stopTimer() {
    if (countdownTimer.isActive) {
      countdownTimer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
            onTap: () {
              BlocProvider.of<GeneralCubit>(context).changeContent =
                  SendEmailConfirm();
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
          "Add the Code",
          style: GoogleFonts.roboto(
            fontSize: 20,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "We have sent the code to ${widget.email}",
          style: GoogleFonts.roboto(fontSize: 15, color: Colors.black54),
        ),

        SizedBox(
          height: 40,
        ),
        Column(
          children: [
            Form(
              key: _formKey,
              child: PinCodeTextField(
                validator: (value) {
                  if (value == null || value.isEmpty || value == "") {
                    return "The OTP field is required.";
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Please enter a valid Code';
                  }
                  return null;
                },
                autoDisposeControllers: false,
                appContext: context,
                autoFocus: true,
                length: 6,
                obscureText: false,
                animationType: AnimationType.fade,
                textInputAction: TextInputAction.next,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 60,
                  fieldWidth: 60,
                  activeFillColor: Colors.white,
                ),
                animationDuration: Duration(milliseconds: 300),
                onChanged: (value) {
                  // Handle OTP changes
                },
                onCompleted: (value) {
                  // Handle OTP completion
                  print("Completed: $value");
                },
                controller: otpController,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Make sure to check your Spam Folder",
              style: GoogleFonts.roboto(fontSize: 15, color: Colors.black54),
            ),
            SizedBox(height: 5,),
            resendTime != 0
                ? Text("Send Code Again 00:$resendTime")
                :  RichText(
              text: TextSpan(
                text: "No Message Received? ",
                style: TextStyle(
                    color: Colors.black38, fontWeight: FontWeight.w500),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Resend Code',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        EasyLoading.show(status: "Loading...");
                        UserDataService()
                            .forgotPassword(email: widget.email
                        )
                            .then((value) {
                          if (value.message == "We have emailed your password reset link.") {
                            EasyLoading.showSuccess("We have resent the code to ${widget.email}",
                                duration: const Duration(seconds: 3), dismissOnTap: true);
                            otpController.clear();
                          } else {
                            EasyLoading.showError(value.message!,
                                duration: const Duration(seconds: 3), dismissOnTap: true);
                          }
                        }).whenComplete(() {
                          EasyLoading.dismiss();
                        });

                      },
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
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xFF133BAD)),
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
                        Timer(const Duration(seconds: 3), () {
                          setState(() {
                            ignorePointer = false;
                          });
                        });
                      });
                      EasyLoading.show(status: "Loading...");
                      UserDataService()
                          .checkOtp(code: otpController.text)
                          .then((value) {
                        if (value.message == "Code OTP is Valid") {
                          // EasyLoading.showSuccess(value.message!,
                          //     duration: const Duration(seconds: 3),
                          //     dismissOnTap: true);
                          BlocProvider.of<GeneralCubit>(context)
                              .changeContent = CreateNewPassword(otpCode: otpController.text,);
                        } else {
                          EasyLoading.showError(value.message!,
                              duration: const Duration(seconds: 3),
                              dismissOnTap: true);
                        }
                      }).whenComplete(() {
                        Timer(const Duration(seconds: 5), () {
                          EasyLoading.dismiss();
                        });
                      });
                    }
                  },
                  child: Text(
                    "Verification",
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
