import 'dart:async';

import 'package:binav_avts/page/screen/forgot_password/create_new_password.dart';
import 'package:binav_avts/page/screen/forgot_password/send_email_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../bloc/general/general_cubit.dart';

class SendOtp extends StatefulWidget {
  const SendOtp({Key? key}) : super(key: key);

  @override
  State<SendOtp> createState() => _SendOtpState();
}

class _SendOtpState extends State<SendOtp> {
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
  startTimer(){
   countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
     setState(() {
       resendTime = resendTime - 1;
     });
     if (resendTime < 1) {
       countdownTimer.cancel();
     }  
   });
  }
  stopTimer(){
    if (countdownTimer.isActive) {
      countdownTimer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      width: width <= 540 ? width : width / 2,
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
              onTap: (){
                BlocProvider.of<GeneralCubit>(context).changeContent = SendEmailConfirm();
              },
              child: Icon( Icons.arrow_back)),
          SizedBox(height: 15,),
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
            height: 40,
          ),
          Column(
            children: [
              PinCodeTextField(
                autoDisposeControllers: false,
                appContext: context,
                length: 6,
                obscureText: false,
                animationType: AnimationType.fade,
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
              const SizedBox(
                height: 10,
              ),
              resendTime != 0
              ? Text("Send Code Again 00:$resendTime")
              : SizedBox(),
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
                      BlocProvider.of<GeneralCubit>(context).changeContent = CreateNewPassword();
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
      ),
    );
  }
}