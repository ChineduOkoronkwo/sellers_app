import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sellers_app/widgets/custom_text_filed.dart';
import 'package:sellers_app/widgets/show_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// 1. Perform validation
// 2. Save Image
// 3. Save Form

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
    // TO-DO add image control validator
    if (isValidImage() && _formKey.currentState!.validate()) {}
    print("Signup button was clicked");
  }

  bool isValidImage() {
    if (imageXFile == null) {
      showCustomDialog(context, "Please select an image!");
      return false;
    }
    return true;
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

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required!';
    }
    if (value.length < 5) {
      return 'Password must contain 5 or more characters!';
    }
    if (RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)” + “(?=.*[-+_!@#$%^&*., ?]).+$')
        .hasMatch(value)) {
      return "Password must contain at least 1 lowercase, 1 uppercase, a number and a special character";
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
    if (!RegExp(r'^(\+\d{1,2,3}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}$')
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
