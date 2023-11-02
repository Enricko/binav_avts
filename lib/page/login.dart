import 'package:binav_avts/bloc/user/user_bloc.dart';
import 'package:binav_avts/datasource/user_datasource.dart';
import 'package:binav_avts/page/screen/intro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';

class Login extends StatefulWidget {
  const Login({super.key, this.idClient = ""});
  final String idClient;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Login Form Controller Variable
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool invisible = true;
  bool _isVisible = true;

  // Carousel Variable
  final PageController _pageController = PageController();
  int currentIndex = 0;
  final List<Widget> introPages = [
    const IntroScreen(
        title: "Identifikasi Kapal",
        description:
            "Kemudahan dalam mengakses informasi terkait Identitas Kapal seperti lokasi, arah, dan status Kapal.",
        assets: "assets/intro1.jpg"),
    const IntroScreen(
        title: "Pelacakan Real Time",
        description:
            "Efisiensi dalam mengetahui lokasi kapal secara Real Time pada peta.",
        assets: "assets/intro2.jpg"),
  ];

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().stream.listen((state) { 
      if(state is UserSignedOut && state.type == TypeMessageAuth.Logout) EasyLoading.showSuccess("${state.message}",duration: Duration(milliseconds: 3000),dismissOnTap: true);
    });
  }

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
          return Container(
            child: Row(
              children: [
                width <= 540
                    ? Container()
                    : Container(
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
                Container(
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
                      Expanded(child: Container()),
                      Column(
                        children: [
                          // widget.idClient != null ? Text("Email : ${emailController.text}") :
                          Visibility(
                            visible: _isVisible,
                            child: Container(
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                controller: emailController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(20, 3, 1, 3),
                                  hintText: "Email",
                                  prefixIcon: Icon(Icons.email_outlined),
                                  // hintStyle: Constants.hintStyle,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.blueAccent),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.black38)),
                                  filled: true,
                                  fillColor: Color(0xF2F2F2F),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: passwordController,
                              textInputAction: TextInputAction.next,
                              obscureText: invisible,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(5),
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
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1, color: Colors.blueAccent),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.black38)),
                                filled: true,
                                fillColor: const Color(0xF2F2F2F),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 25),
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    const Color(0xFF133BAD)),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                // _isVisible == true ? loginAdmin() : loginClient();
                                context.read<UserBloc>().add(SignIn(email: emailController.text, password: passwordController.text));
                              },
                              child: const Text(
                                "Log in",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
