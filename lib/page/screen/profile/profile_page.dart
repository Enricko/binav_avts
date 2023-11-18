import 'package:binav_avts/page/screen/profile/send_change_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/profile_widget/profile_widget_bloc.dart';
import '../../../bloc/user/user_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return BlocBuilder<UserBloc, UserState>(builder: (context, state) {
      return Container(
      height: height - 130,
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Center(
                child: CircleAvatar(
                  child: Text(
                    (state is UserSignedIn) ? state.user.user!.name![0] : "",
                    style: TextStyle(fontSize: 30),
                  ),
                  radius: 50,
                )),
            SizedBox(
              height: 10,
            ),
            Text(
              (state is UserSignedIn) ? state.user.user!.name! : "",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text((state is UserSignedIn) ? state.user.user!.email! : ""),
            SizedBox(
              height: 15,
            ),
            ListTile(
              onTap: () {
                context.read<ProfileWidgetBloc>().add(ChangePassword());
              },
              title: Text("Change Password"),
              trailing: Icon(Icons.key),
            ),
            SizedBox(
              height: 15,
            ),
            ListTile(
              onTap: () {
                context.read<ProfileWidgetBloc>().add(LogOut());
              },
              title: Text("Log Out"),
              trailing: Icon(Icons.key),
            ),
          ],
        ),
      ),
    );
  });
}}
