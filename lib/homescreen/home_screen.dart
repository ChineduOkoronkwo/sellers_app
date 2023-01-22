import 'package:flutter/material.dart';
import 'package:sellers_app/authentication/auth_screen.dart';
import 'package:sellers_app/services/local_services.dart';

import '../global/global.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.cyan,
                  Colors.amber,
                ],
                begin:  FractionalOffset(0.0, 0.0),
                end:  FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              )
          ),
        ),
        title: Text(
          getUserName(),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
          ),
          onPressed: ()
          {
            firebaseAuth.signOut().then((value){
              Navigator.push(context, MaterialPageRoute(builder: (c)=> const AuthScreen()));
            });
          },
          child: const Text("Logout"),
        ),
      ),
    );
  }
}