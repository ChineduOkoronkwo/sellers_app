import 'package:flutter/material.dart';
import 'package:sellers_app/widgets/error_dialog.dart';
import 'package:sellers_app/widgets/loading_dialog.dart';

Future<void> showCustomDialog(BuildContext context, Widget dialog) async {
  return showDialog<void>(
      context: context,
      builder: (c) {
        return dialog;
      });
}

Future<void> showErrorDialog(BuildContext context, String message) {
  return showCustomDialog(context, ErrorDialog(message: message));
}

Future<void> showLoadingDialog(BuildContext context, String message) {
  return showCustomDialog(context, LoadingDialog(message: message));
}