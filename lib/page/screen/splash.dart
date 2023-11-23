// ignore_for_file: use_build_context_synchronously

import 'package:binav_avts/bloc/user/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigateHome();
  }

  _navigateHome() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var userBloc = context.read<UserBloc>();
    await Future.delayed(const Duration(seconds: 3));
    if (userBloc.state is UserSignedOut && pref.getString('token') == null) {
      context.goNamed('login');
    } else if (userBloc.state is UserSignedIn && pref.getString('token') != null) {
      if (pref.getString("level") == "client") {
        context.goNamed("main_page_client", pathParameters: {'id_client': pref.getString("idClient")!});
      } else {
        context.goNamed("main_page");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/logo.png",
          height: 40,
        ),
      ),
    );
  }
}
