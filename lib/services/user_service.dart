import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fstore;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

SharedPreferences? sharedPreferences;

FirebaseAuth getFirebaseAuth() {
  return FirebaseAuth.instance;
}

String getCollection() {
  return "sellers";
}

Future<String> uploadImage(String path, [String? filename]) async {
  filename ??= const Uuid().v1();
  String? imageUrl;
  fstore.Reference reference =
      fstore.FirebaseStorage.instance.ref().child("sellers").child(filename);
  fstore.UploadTask uploadTask = reference.putFile(File(path));
  fstore.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
  await taskSnapshot.ref.getDownloadURL().then((url) {
    imageUrl = url;
  });
  return imageUrl!;
}

Future<User> createSeller(String email, String password) async {
  User? currentUser;
  await getFirebaseAuth()
      .createUserWithEmailAndPassword(email: email, password: password)
      .then((auth) => {currentUser = auth.user});
  return currentUser!;
}

Future<void> saveUserData(String uid, String email, String name, String imageUrl, String phone, String address, Position position) async {
  FirebaseFirestore.instance.collection("sellers").doc(uid).set({
    "sellerUID": uid,
    "sellerEmail": email,
    "sellerName": name,
    "sellerAvatarUrl": imageUrl,
    "phone": phone,
    "address": address,
    "status": "approved",
    "earnings": 0.0,
    "lat": position.latitude,
    "lng": position.longitude,
  });
}

Future<void> setUserDataLocally(String uid) async {
  await FirebaseFirestore.instance
      .collection("sellers")
      .doc(uid)
      .get()
      .then((snapshot) async {
    sharedPreferences ??= await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", uid);
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
