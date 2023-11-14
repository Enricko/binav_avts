import 'dart:async';

import 'package:binav_avts/bloc/user/user_bloc.dart';
import 'package:binav_avts/page/profile_page.dart';
import 'package:binav_avts/services/user_dataservice.dart';
import 'package:binav_avts/page/screen/intro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/general/general_cubit.dart';

class Login extends StatefulWidget {
  const Login({super.key, this.idClient = ""});

  final String idClient;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  // Login Form Controller Variable
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  TextEditingController otpController = TextEditingController();

  bool invisible = true;
  final bool _isVisible = true;
  bool ignorePointer = false;

  bool isForgotPassword = true;
  bool sendEmailPage = true;

  // Carousel Variable
  // final PageController _pageController = PageController();

  int currentIndex = 0;
  final List<Widget> introPages = [
    const IntroScreen(
        title: "Identifikasi Kapal",
        description:
            "Kemudahan dalam mengakses informasi terkait Identitas dan Lokasi Kapal.",
        assets: "assets/intro1.jpg"),
    const IntroScreen(
        title: "Pelacakan Real Time",
        description:
            "Efisiensi dalam mengetahui Koordinat kapal secara Real Time pada peta.",
        assets: "assets/intro2.jpg"),
    const IntroScreen(
        title: "Optimalisasi",
        description:
            "Pengoptimalan Rute dan operasi Kapal dengan data yang akurat tentang pergerakan kapal.",
        assets: "assets/intro3.jpg"),
  ];



  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "AVTS - Automated Vessel Tracking System",
          style: GoogleFonts.montserrat(fontSize: 15, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0E286C),
        iconTheme: const IconThemeData(
          color: Colors.white, // Change this color to the desired color
        ),
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          return Row(
            children: [
              width <= 540
                  ? Container()
                  : SizedBox(
                      // color: Color(0xFF2B3B9A),
                      width: width / 2,
                      height: double.infinity,
                      child: Column(
                        children: [
                          Expanded(
                            child: CarouselSlider(
                                options: CarouselOptions(
                                  height: double.infinity,
                                  autoPlay: true,
                                  viewportFraction: 1.0,
                                  autoPlayAnimationDuration:
                                      const Duration(milliseconds: 3000),
                                  // viewportFraction: 0.8,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      currentIndex = index;
                                    });
                                  },
                                ),
                                items: introPages),
                          ),
                          DotsIndicator(
                            dotsCount: introPages.length,
                            position: currentIndex,
                            decorator: const DotsDecorator(
                              color: Colors.grey,
                              activeColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
              SingleChildScrollView(
                  child: isForgotPassword
                      ? BlocProvider.of<GeneralCubit>(context).forgotPasswordContent
                      : Container(
                          width: width <= 540 ? width : width / 2,
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                "assets/logo.png",
                                height: 40,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "${widget.idClient}"
                                "Hai Welcome to Binav AVTS\n"
                                "Log in to your Account",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              Container(
                                constraints:
                                    const BoxConstraints(minHeight: 100),
                              ),
                              Column(
                                children: [
                                  // widget.idClient != null ? Text("Email : ${emailController.text}") :
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        Visibility(
                                          visible: _isVisible,
                                          child: TextFormField(
                                            autofillHints: [
                                              AutofillHints.email
                                            ],
                                            keyboardType: TextInputType.text,
                                            controller: emailController,
                                            textInputAction:
                                                TextInputAction.next,
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
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      20, 3, 1, 3),
                                              hintText: "Email",
                                              prefixIcon:
                                                  Icon(Icons.email_outlined),
                                              // hintStyle: Constants.hintStyle,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.blueAccent),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.black38)),
                                              errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.redAccent)),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          width: 1,
                                                          color: Colors
                                                              .redAccent)),
                                              filled: true,
                                              fillColor: Color(0x0f2f2f2f),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        TextFormField(
                                          keyboardType: TextInputType.text,
                                          controller: passwordController,
                                          textInputAction: TextInputAction.next,
                                          obscureText: invisible,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty ||
                                                value == "") {
                                              return "The Password field is required.";
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.all(5),
                                            hintText: "Password",
                                            prefixIcon: const Icon(Icons.key),
                                            suffixIcon: IconButton(
                                              icon: Icon((invisible == true)
                                                  ? Icons.visibility_outlined
                                                  : Icons.visibility_off),
                                              onPressed: () {
                                                setState(() {
                                                  invisible = !invisible;
                                                });
                                              },
                                            ),
                                            // hintStyle: Constants.hintStyle,
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors.blueAccent),
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        width: 1,
                                                        color: Colors.black38)),
                                            errorBorder:
                                                const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        width: 1,
                                                        color:
                                                            Colors.redAccent)),
                                            focusedErrorBorder:
                                                const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        width: 1,
                                                        color:
                                                            Colors.redAccent)),
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
                                  Row(
                                    children: [
                                      Checkbox(
                                          value: false,
                                          onChanged: (bool? value) {}),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(child: Text("Remember me")),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            isForgotPassword = !isForgotPassword;
                                          });
                                        },
                                        child: Text(
                                          "Forgotten Password",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    state is UserSignedOut &&
                                            state.type == TypeMessageAuth.Error
                                        ? state.message
                                        : "",
                                    style: const TextStyle(
                                        color: Colors.redAccent),
                                  ),
                                  const SizedBox(
                                    height: 10,
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
                                              MaterialStateProperty.all(
                                                  const Color(0xFF133BAD)),
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          // _isVisible == true ? loginAdmin() : loginClient();
                                          if (_formKey.currentState!
                                              .validate()) {
                                            setState(() {
                                              ignorePointer = true;
                                              Timer(const Duration(seconds: 3),
                                                  () {
                                                setState(() {
                                                  ignorePointer = false;
                                                  print(ignorePointer);
                                                });
                                              });
                                            });
                                            await EasyLoading.show(
                                                status: "Loading...");
                                            context.read<UserBloc>().add(SignIn(
                                                email: emailController.text,
                                                password:
                                                    passwordController.text));
                                          }
                                        },
                                        child: const Text(
                                          "Log in",
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
                        )),
            ],
          );
        },
      ),
    );
  }

  Container sendOtpContent(double width) {
    return Container(
      width: width <= 540 ? width : width / 2,
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
              onTap: (){
                setState(() {
                  sendEmailPage = !sendEmailPage;
                });
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
          // SizedBox(height: 10,),
          // Text(
          //   "Enter your email below, and we'll send an email with confirmation to reset your password",
          //   style:  GoogleFonts.roboto(
          //       fontSize: 15,color: Colors.black38 ),),
          SizedBox(
            height: 40,
          ),
          Column(
            children: [
              // widget.idClient != null ? Text("Email : ${emailController.text}") :
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
                      // _isVisible == true ? loginAdmin() : loginClient();
                      // if (_formKey.currentState!.validate()) {
                      //   setState(() {
                      //     ignorePointer = true;
                      //     Timer(const Duration(seconds: 3), () {
                      //       setState(() {
                      //         ignorePointer = false;
                      //         print(ignorePointer);
                      //       });
                      //     });
                      //   });
                      //   await EasyLoading.show(
                      //       status: "Loading...");
                      //   context.read<UserBloc>().add(SignIn(
                      //       email: emailController.text,
                      //       password: passwordController.text));
                      // }
                    },
                    child: Text(
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
      ),
    );
  }

  Container sendEmailContent(double width) {
    return Container(
      width: width <= 540 ? width : width / 2,
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              // widget.idClient != null ? Text("Email : ${emailController.text}") :
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
                        if (!RegExp(
                                r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(5),
                        hintText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: Colors.blueAccent),
                        ),
                        enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Colors.black38)),
                        errorBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Colors.redAccent)),
                        focusedErrorBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Colors.redAccent)),
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
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xFF133BAD)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    onPressed: () async {
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
      ),
    );
  }
}


