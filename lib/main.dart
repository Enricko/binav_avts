import 'dart:async';

import 'package:binav_avts/bloc/auth_widget/auth_widget_bloc.dart';
import 'package:binav_avts/bloc/general/general_cubit.dart';
import 'package:binav_avts/bloc/user/user_bloc.dart';
import 'package:binav_avts/bloc/websocket/socket_cubit.dart';
import 'package:binav_avts/services/client_dataservice.dart';
import 'package:binav_avts/services/user_dataservice.dart';
import 'package:binav_avts/page/first_screen.dart';
import 'package:binav_avts/page/main_page.dart';
import 'package:binav_avts/page/screen/splash.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..userInteractions = true
    ..animationStyle = EasyLoadingAnimationStyle.scale
    ..maskType = EasyLoadingMaskType.black;
  // ..customAnimation = CustomAnimation();
}

void main() {
  // usePathUrlStrategy();
  runApp(MyApp());
  configLoading();
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GoRouter router = GoRouter(routes: [
    GoRoute(
      path: '/',
      name: 'splash_screen',
      builder: (context, state) {
        return const Splash();
      },
      routes: [
        GoRoute(
          path: 'login',
          name: 'login',
          builder: (context, state) {
            return const FirstScreen();
          },
          redirect: (context, state) async {
            SharedPreferences pref = await SharedPreferences.getInstance();
            var userBloc = context.read<UserBloc>();
            await Future.delayed(const Duration(seconds: 3));
            if (userBloc.state is UserSignedOut && pref.getString('token') == null) {
              return '/login';
            } else if (userBloc.state is UserSignedIn && pref.getString('token') != null) {
              if (pref.getString('level') == 'client') {
                return '/main_page/${pref.getString('idClient')}';
              }else{
                return '/main_page';
              }
            }
            return null;
          },
        ),
        GoRoute(
          path: 'main_page',
          name: 'main_page',
          builder: (context, state) {
            return const MainPage();
          },
          redirect: (context, states) async {
            SharedPreferences pref = await SharedPreferences.getInstance();
            var userBloc = context.read<UserBloc>();
            if (userBloc.state is UserSignedOut && pref.getString('token') == null) {
              return '/login';
            } else {
              if (pref.getString('level') == 'client') {
                return '/main_page/${pref.getString('idClient')}';
              } else {
                return '/main_page';
              }
            }
          },
        ),
        GoRoute(
          path: 'main_page/:id_client',
          name: 'main_page_client',
          builder: (context, state) {
            return MainPage(idClient: state.pathParameters['id_client'].toString());
          },
          redirect: (context, state) async {
            SharedPreferences pref = await SharedPreferences.getInstance();
            var userBloc = context.read<UserBloc>();
            var client = await ClientDataService().getClientById(token: pref.getString('token')!, id_client: state.pathParameters['id_client'].toString());
            if (userBloc.state is UserSignedOut && pref.getString('token') == null) {
              return '/login';
            } else if(userBloc.state is UserSignedIn && pref.getString('token') != null){
              if (pref.getString('level') == 'client') {
                return '/main_page/${pref.getString('idClient')}';
              }
              print(client.message);
              if(client.message == "Data Client Ditemukan"){
                EasyLoading.showSuccess("Going To Client Map ${client.data!.first.clientName}",duration: Duration(seconds: 3),dismissOnTap: true);
                return '/main_page/${client.data!.first.idClient!}';
              }else{
                EasyLoading.showError("ID Client Not Found",duration: Duration(seconds: 3),dismissOnTap: true);
                return '/main_page';
              }
            }
            return null;
          },
        ),
      ],
    ),
  ], initialLocation: '/', debugLogDiagnostics: true, routerNeglect: true);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserBloc(userDataSource: UserDataService())..add(CheckSignInStatus()),
        ),
        BlocProvider(create: (BuildContext context) => SocketCubit()..listen()),
        BlocProvider(create: (BuildContext context) => GeneralCubit()),
        BlocProvider(create: (BuildContext context) => AuthWidgetBloc()),
      ],
      child: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserSignedIn) {
            if (state.user.user!.level == "client") {
              router.goNamed("main_page_client", pathParameters: {'id_client': state.user.client!.idClient!});
            } else {
              router.goNamed("main_page");
            }
          } else if (state is UserSignedOut) {
            router.goNamed('login');
          }
        },
        child: MaterialApp.router(
          title: 'Binav AVTS',
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          routeInformationProvider: router.routeInformationProvider,
          debugShowCheckedModeBanner: false,
          builder: EasyLoading.init(),
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus,
              PointerDeviceKind.unknown
            },
          ),
          // home: const MyHomePage(title: 'Flutter Demo Home Page'),
        ),
      ),
    );
  }
}
