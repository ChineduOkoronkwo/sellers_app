import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? sharedPreferences;

Future<void> setUserDataLocally(User currentUser) async {
  await FirebaseFirestore.instance
      .collection("sellers")
      .doc(currentUser.uid)
      .get()
      .then((snapshot) async {
    sharedPreferences ??= await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!
        .setString("email", snapshot.data()!["sellerEmail"]);
    await sharedPreferences!.setString("name", snapshot.data()!["sellerName"]);
    await sharedPreferences!
        .setString("photoUrl", snapshot.data()!["sellerAvatarUrl"]);
  });
}

String getUserName() {
  return sharedPreferences!.getString("name")!;
}
