import 'dart:async';

import 'package:binav_avts/page/screen/forgot_password/send_email_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../bloc/general/general_cubit.dart';
import '../../bloc/user/user_bloc.dart';
import '../../services/client_dataservice.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.idClient = ""});

  final String idClient;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool invisible = true;
  final bool _isVisible = true;

  bool ignorePointer = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
      return Column(
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
        Container(
          constraints:
          const BoxConstraints(minHeight: 100),
        ),
        Column(
          children: [
            // widget.idClient != null ? Text("Email : ${emailController.text}") :
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Visibility(
                    visible: _isVisible,
                    child: TextFormField(
                      autofillHints: [
                        AutofillHints.email
                      ],
                      keyboardType: TextInputType.text,
                      controller: emailController,
                      textInputAction:
                      TextInputAction.next,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value == "") {
                          return "The Email field is required.";
                        }
                        if (!RegExp(
                            r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        contentPadding:
                        EdgeInsets.fromLTRB(
                            20, 3, 1, 3),
                        hintText: "Email",
                        prefixIcon:
                        Icon(Icons.email_outlined),
                        // hintStyle: Constants.hintStyle,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1,
                              color: Colors.blueAccent),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1,
                                color: Colors.black38)),
                        errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1,
                                color: Colors.redAccent)),
                        focusedErrorBorder:
                        OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1,
                                color: Colors
                                    .redAccent)),
                        filled: true,
                        fillColor: Color(0x0f2f2f2f),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: passwordController,
                    textInputAction: TextInputAction.next,
                    obscureText: invisible,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value == "") {
                        return "The Password field is required.";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding:
                      const EdgeInsets.all(5),
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
                      focusedBorder:
                      const OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 1,
                            color: Colors.blueAccent),
                      ),
                      enabledBorder:
                      const OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1,
                              color: Colors.black38)),
                      errorBorder:
                      const OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1,
                              color:
                              Colors.redAccent)),
                      focusedErrorBorder:
                      const OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1,
                              color:
                              Colors.redAccent)),
                      filled: true,
                      fillColor: const Color(0x0f2f2f2f),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Checkbox(
                    value: false,
                    onChanged: (bool? value) {}),
                SizedBox(
                  width: 10,
                ),
                Expanded(child: Text("Remember me")),
                TextButton(
                  onPressed: () {
                    BlocProvider.of<GeneralCubit>(context).changeContent = SendEmailConfirm();
                  },
                  child: Text(
                    "Forgotten Password",
                    style: TextStyle(color: Colors.blue),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              state is UserSignedOut &&
                  state.type == TypeMessageAuth.Error
                  ? state.message
                  : "",
              style: const TextStyle(
                  color: Colors.redAccent),
            ),
            const SizedBox(
              height: 10,
            ),
            IgnorePointer(
              ignoring: ignorePointer,
              child: Container(
                margin: const EdgeInsets.only(bottom: 25),
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all(
                        const Color(0xFF133BAD)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    // _isVisible == true ? loginAdmin() : loginClient();
                    if (_formKey.currentState!
                        .validate()) {
                      setState(() {
                        ignorePointer = true;
                        Timer(const Duration(seconds: 3),
                                () {
                              setState(() {
                                ignorePointer = false;
                                print(ignorePointer);
                              });
                            });
                      });
                      await EasyLoading.show(
                          status: "Loading...");
                      context.read<UserBloc>().add(SignIn(
                          email: emailController.text,
                          password:
                          passwordController.text));
                    }
                  },
                  child: const Text(
                    "Log in",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ); });
  }
}
