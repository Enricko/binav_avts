import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() { 
    super.initState();
    // _navigateHome();
  }

  // _navigateHome()async{
  //   await Future.delayed(Duration(milliseconds: 1500),(){
  //     context.goNamed("main_page");
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Splash Screen"),
      ),
    );
  }
}