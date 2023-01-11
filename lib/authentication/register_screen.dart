import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sellers_app/widgets/custom_text_filed.dart';

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

  Future<void> _getImage() async {
    imageXFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  void signup() {
    print("Signup button was clicked");
  }

  void getCurrentLocation() {
    print("Location button was clicked");
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
      ),
      CustomTextField(
        controller: confirmPasswordController,
        iconData: Icons.lock,
        hintText: "Confirm Password",
        obscureText: true,
      ),
      CustomTextField(
          controller: phoneController,
          iconData: Icons.phone,
          hintText: "Phone"),
      CustomTextField(
          controller: locationController,
          iconData: Icons.my_location,
          hintText: "Address"),
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
        minimumSize: const Size.fromHeight(50)
      ),
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
