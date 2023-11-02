import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    return Scaffold(
      body: Center(
        child: Container(
          child: Text("Splash Screen"),
        ),
      ),
    );
  }
}