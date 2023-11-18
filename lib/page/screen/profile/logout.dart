import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/profile_widget/profile_widget_bloc.dart';
import '../../../bloc/user/user_bloc.dart';

class LogOutPage extends StatefulWidget {
  const LogOutPage({Key? key}) : super(key: key);

  @override
  State<LogOutPage> createState() => _LogOutPageState();
}

class _LogOutPageState extends State<LogOutPage> {

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return  BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
      return Container(
      height: height - 130,
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
                onTap: () {
                  context.read<ProfileWidgetBloc>().add(Profile());
                },
                child: Icon(Icons.arrow_back)),
            Center(child: Text("Do You Wanna Log Out?")),

          ],
        ),
      ),
    );
  });
}}
