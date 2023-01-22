import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sellers_app/global/global.dart';
import 'package:sellers_app/widgets/custom_text_filed.dart';
import 'package:sellers_app/widgets/show_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart' as fstore;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../homescreen/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// 1. Perform validation => done
// 2. Get Location => done
// 2. Save Image => done
// 3. Save Form =>

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  XFile? imageXFile;
  final ImagePicker _imagePicker = ImagePicker();
  Position? position;
  List<Placemark>? placemarks;

  Future<void> _getImage() async {
    imageXFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
          'Location services are disabled! Please enable it to proceed.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied!');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Unable to reqest permission! Location permissions are permanently denied.');
    }

    position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    placemarks =
        await placemarkFromCoordinates(position!.latitude, position!.longitude);

    Placemark pMark = placemarks![0];
    locationController.text =
        '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';
  }

  Future<void> signup() async {
    if (isValidImage() && _formKey.currentState!.validate()) {
      // show loading dialog
      showLoadingDialog(context, "Processing...");

      // upload image to firebase cloud storage
      var filename = const Uuid().v1();
      String? sellerImageUrl;
      fstore.Reference reference = fstore.FirebaseStorage.instance
          .ref()
          .child("sellers")
          .child(filename);
      fstore.UploadTask uploadTask = reference.putFile(File(imageXFile!.path));
      fstore.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      await taskSnapshot.ref.getDownloadURL().then((url) {
        sellerImageUrl = url;
      });

      // create seller and sign in
      await createSellerAndSignUp(sellerImageUrl!).then((value) {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const HomeScreen()));
      }).catchError((error, stackTrace) {
        // Ideally, error should be pushed to a remote server.
        showErrorDialog(context, error.toString());
      });
    }
  }

  Future<void> createSellerAndSignUp(String sellerImageUrl) async {
    User? currentUser;
    await firebaseAuth
        .createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((auth) => {currentUser = auth.user});

    if (currentUser != null) {
      await saveUserDate(currentUser!, sellerImageUrl);
    }
  }

  Future<void> saveUserDate(User currentUser, String sellerImageUrl) async {
    FirebaseFirestore.instance.collection("sellers").doc(currentUser.uid).set({
      "sellerUID": currentUser.uid,
      "sellerEmail": currentUser.email,
      "sellerName": nameController.text.trim(),
      "sellerAvatarUrl": sellerImageUrl,
      "phone": phoneController.text.trim(),
      "address": locationController.text,
      "status": "approved",
      "earnings": 0.0,
      "lat": position!.latitude,
      "lng": position!.longitude,
    });

    // save data locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", currentUser.email.toString());
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("photoUrl", sellerImageUrl);
  }

  bool isValidImage() {
    if (imageXFile == null) {
      showErrorDialog(context, "Please select an image!");
      return false;
    }
    return true;
  }

  String? validateAddressField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    return null;
  }

  String? validateNameField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? validateEmailField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
        .hasMatch(value)) {
      return null;
    }
    return 'Email address is invalid';
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required!';
    }
    if (!RegExp(r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?!.*\s).{6,13}$')
        .hasMatch(value)) {
      return "Password must contain at least 1 lowercase, 1 uppercase, a number and a number and must be 6 to 13 characters long";
    }
    return null;
  }

  String? validateConfirmPass(String? confirmPassword, String? password) {
    if (confirmPassword == null) {
      return "Confirm password is required!";
    }
    if (password == null || confirmPassword != password) {
      return "Confirm password does not match!";
    }
    return null;
  }

  String? validateConfirmPasswword(String? value) {
    return validateConfirmPass(value, passwordController.text);
  }

  String? validatePhoneField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone is required';
    }
    if (!RegExp(r'^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$')
        .hasMatch(value)) {
      return "Phone is invalid!";
    }
    return null;
  }

  InkWell _getImagePicker() {
    return InkWell(
        onTap: _getImage,
        child: CircleAvatar(
          radius: MediaQuery.of(context).size.width * 0.20,
          backgroundColor: Colors.white,
          backgroundImage:
              imageXFile == null ? null : FileImage(File(imageXFile!.path)),
          child: _getImageIcon(context),
        ));
  }

  Widget? _getImageIcon(BuildContext context) {
    if (imageXFile == null) {
      return Icon(
        Icons.add_photo_alternate,
        size: MediaQuery.of(context).size.width * 0.20,
        color: Colors.grey,
      );
    }
    return null;
  }

  List<Widget> _getTextFields() {
    return [
      CustomTextField(
        controller: nameController,
        iconData: Icons.person,
        hintText: "Name",
        validator: validateNameField,
      ),
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
      CustomTextField(
        controller: confirmPasswordController,
        iconData: Icons.lock,
        hintText: "Confirm Password",
        obscureText: true,
        validator: validateConfirmPasswword,
      ),
      CustomTextField(
        controller: phoneController,
        iconData: Icons.phone,
        hintText: "Phone",
        validator: validatePhoneField,
      ),
      CustomTextField(
        controller: locationController,
        iconData: Icons.my_location,
        hintText: "Address",
        validator: validateAddressField,
      ),
      _getLocationButton(),
      const SizedBox(
        height: 20,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: _getElevatedButton(),
      ),
    ];
  }

  ElevatedButton _getElevatedButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          minimumSize: const Size.fromHeight(50)),
      onPressed: signup,
      child: const Text(
        "Sign Up",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _getLocationButton() {
    return Container(
      width: 400,
      height: 40,
      alignment: Alignment.center,
      child: ElevatedButton.icon(
        onPressed: getCurrentLocation,
        icon: const Icon(
          Icons.location_on,
          color: Colors.white,
        ),
        label: const Text(
          "Get my Current Location",
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyan,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
          const SizedBox(
            height: 10,
          ),
          _getImagePicker(),
          const SizedBox(
            height: 10,
          ),
          Form(
            key: _formKey,
            child: Column(
              children: _getTextFields(),
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
