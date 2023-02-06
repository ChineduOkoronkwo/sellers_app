import "package:flutter/material.dart";
import 'package:sellers_app/authentication/auth_screen.dart';
import 'package:sellers_app/services/user_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Divider _getDivider() {
    return const Divider(
      height: 10,
      color: Colors.grey,
      thickness: 2,
    );
  }

  ListTile _getListTitle(IconData iconData, String texttitle, Function() onClicked) {
    return ListTile(
      leading: Icon(iconData, color: Colors.black,),
      title:  Text(
        texttitle,
        style: const TextStyle(color: Colors.black),
      ),

        onTap: onClicked,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 25, bottom: 10),
            child: Column(
              children: [
                Material(
                  borderRadius: const BorderRadius.all(Radius.circular(80)),
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(1),
                    child: Container(
                      height: 160,
                      width: 160,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(getPhotoUrl()),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  getUserName(),
                  style: const TextStyle(
                      color: Colors.black, fontSize: 20, fontFamily: "Train"),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // body drawer
          Container(
            padding: const EdgeInsets.only(top: 1.0),
            child: Column(
              children: [
                _getDivider(),
                _getListTitle(Icons.home, "Home", (){}),
                _getDivider(),
                _getListTitle(Icons.reorder, "My Orders", (){}),
                _getDivider(),
                _getListTitle(Icons.access_time, "History", (){}),
                _getDivider(),
                _getListTitle(Icons.search, "Search", (){}),
                _getDivider(),
                _getListTitle(Icons.add_location, "Add New Address", (){}),
                _getDivider(),
                _getListTitle(Icons.exit_to_app, "Sign Out", (){
                  getFirebaseAuth().signOut().then((value) {
                    Navigator.push(context,
                    MaterialPageRoute(builder: (c) => const AuthScreen()));
                  });
                }),
                _getDivider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
