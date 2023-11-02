import 'package:binav_avts/bloc/user/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Page"),
      ),
      body: Center(
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Main Page'),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(state is UserSignedIn ? state.user.user!.name.toString() : ""),
                  Text(state is UserSignedIn ? state.user.user!.email.toString() : ""),
                  Text(state is UserSignedIn ? state.user.user!.idUser.toString() : ""),
                  Text(state is UserSignedIn ? state.user.client!.idClient.toString() : ""),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          context.read<UserBloc>().add(SignOut());
                        });
                      },
                      child: const Text("Logout")),
                ]);
          },
        ),
      ),
    );
  }
}
