import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final IconData? iconData;
  final String? hintText;
  final Color iconColor;
  final InputBorder? inputBorder;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;

  CustomTextField({
    required this.controller,
    required this.iconData,
    required this.hintText,
    this.inputBorder = InputBorder.none,
    this.validator,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.iconColor = Colors.cyan,
  });

  @override
  Widget build(BuildContext context) {
    // final inputBorder = OutlineInputBorder(
    //   borderSide: Divider.createBorderSide(context),
    // );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(10),
      child: TextFormField(
        enabled: enabled,
        readOnly: readOnly,
        controller: controller,
        obscureText: obscureText,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          border: inputBorder,
          prefixIcon: Icon(
            iconData,
            color: iconColor,
          ),
          focusColor: Theme.of(context).primaryColor,
          hintText: hintText,
        ),
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }
}