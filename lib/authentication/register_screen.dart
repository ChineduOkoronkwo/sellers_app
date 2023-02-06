import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sellers_app/services/user_service.dart';
import 'package:sellers_app/widgets/custom_text_filed.dart';
import 'package:sellers_app/widgets/show_dialog.dart';

import '../homescreen/home_screen.dart';
import '../validation/user_validation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

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

      await uploadImage(imageXFile!.path).then((url) async {
        var user =
            await createSeller(emailController.text, passwordController.text);
        await saveUserData(
          user.uid,
          emailController.text,
          nameController.text,
          url,
          phoneController.text,
          locationController.text,
          position!,
        );
        await setUserDataLocally(user.uid);
      }).then((value) {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
      }).catchError((error) {
        Navigator.pop(context);
        // Ideally, error should be pushed to a remote server.
        showErrorDialog(context, error.toString());
      });
    }
  }

  bool isValidImage() {
    if (imageXFile == null) {
      showErrorDialog(context, "Please select an image!");
      return false;
    }
    return true;
  }

  String? validateConfirmPasswword(String? value) {
    return validateConfirmPass(value, passwordController.text);
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
