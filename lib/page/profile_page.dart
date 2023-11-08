import 'package:binav_avts/bloc/user/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SizedBox(
      width: width/3.2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.black12,
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Profile Page",
                  style: GoogleFonts.openSans(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          BlocBuilder<UserBloc,UserState>(
            builder: (context,state) {
              return Container(
                height: height - 130,
                padding: EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(child: CircleAvatar(
                        child: Text((state is UserSignedIn) ? state.user.user!.name![0] : "",style: TextStyle(fontSize: 30), ),
                        radius: 50,)),
                      SizedBox(height: 10,),
                      Text((state is UserSignedIn) ? state.user.user!.name! : ""),
                      SizedBox(height: 10,),
                      ListTile(
                        onTap: (){

                        },
                        title: Text("Change Password"),
                      ),
                    ],
                  ),
                ),
              );
            }
          )
        ],
      ),
    );
  }
}
