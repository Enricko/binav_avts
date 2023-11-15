import 'package:binav_avts/bloc/general/general_cubit.dart';
import 'package:binav_avts/bloc/user/user_bloc.dart';
import 'package:binav_avts/bloc/websocket/socket_cubit.dart';
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
        return Splash();
      },
      routes: [
        GoRoute(
          path: 'login',
          name: 'login',
          builder: (context, state) {
            return FirstScreen();
          },
        ),
        GoRoute(
          path: 'main_page',
          name: 'main_page',
          builder: (context, state) {
            return MainPage();
          },
        ),
        // GoRoute(
        //   path: 'login-client/:client',
        //   builder: (BuildContext context, GoRouterState state) {

        //     return Login(idClient: state.pathParameters['client'].toString());
        //     // ClientMaps(idClient:state.pathParameters['client'].toString());
        //   },
        // ),
      ],
    ),
  ], initialLocation: '/', debugLogDiagnostics: true, routerNeglect: true);

  @override
  void initState() {
    super.initState();
    // WebSocketDataService().run();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserBloc(userDataSource: UserDataService())..add(CheckSignInStatus()),
        ),
        BlocProvider(create: (BuildContext context) => SocketCubit()..listen()),
        BlocProvider(create: (BuildContext context) => GeneralCubit()),
      ],
      child: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserSignedIn) {
            router.goNamed("main_page");
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
          scrollBehavior: MaterialScrollBehavior().copyWith(
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
