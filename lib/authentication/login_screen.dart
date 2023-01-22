import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sellers_app/homescreen/home_screen.dart';
import 'package:sellers_app/validation/user_validation.dart';
import 'package:sellers_app/widgets/show_dialog.dart';

import '../services/user_service.dart';
import '../widgets/custom_text_filed.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      showLoadingDialog(context, 'Validating...');
    }

    User? currentUser;
    await getFirebaseAuth()
        .signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((auth) {
      currentUser = auth.user!;
    }).catchError((error) {
      Navigator.pop(context);
      showErrorDialog(context, error.toString());
    });

    if (currentUser != null) {
      await setUserDataLocally(currentUser!.uid).then((value) {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const HomeScreen()));
      }).catchError((error) {
        Navigator.pop(context);
        showErrorDialog(context, error.toString());
      });
    }
  }

  Widget _getDpImage() {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Image.asset(
          "images/seller.png",
          height: 270,
        ),
      ),
    );
  }

  ElevatedButton _getElevatedButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          minimumSize: const Size.fromHeight(50)),
      onPressed: login,
      child: const Text(
        "Login",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _getDpImage(),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: emailController,
                  iconData: Icons.email,
                  hintText: "Email",
                  validator: validateEmailField,
                ),
                CustomTextField(
                  controller: passwordController,
                  iconData: Icons.lock,
                  hintText: "Password",
                  obscureText: true,
                  validator: validatePassword,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _getElevatedButton(),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
