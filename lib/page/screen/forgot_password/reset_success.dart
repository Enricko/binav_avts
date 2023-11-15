import 'package:binav_avts/page/screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../bloc/general/general_cubit.dart';

class ResetSuccess extends StatefulWidget {
  const ResetSuccess({Key? key}) : super(key: key);

  @override
  State<ResetSuccess> createState() => _ResetSuccessState();
}

class _ResetSuccessState extends State<ResetSuccess> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/lottie/animation_success.json', // Replace with the actual path to your animation file
          width: 250,
          fit: BoxFit.cover,
        ),
        Text(
          "Password Changed",
          style: GoogleFonts.roboto(
            fontSize: 20,
          ),
        ),
        SizedBox(height: 10,),
        Text(
          "Your password has been changed successful",
          style:  GoogleFonts.roboto(
              fontSize: 15,color: Colors.black54 ),),
        SizedBox(height: 10,),
        Container(
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
              BlocProvider.of<GeneralCubit>(context)
                  .changeContent = LoginPage();
            },
            child: Text(
              "Back to Login",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );;
  }
}
