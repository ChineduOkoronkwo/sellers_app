import 'package:flutter/material.dart';
import 'package:sellers_app/widgets/error_dialog.dart';

Future<void> showCustomDialog(BuildContext context, String message) async {
  return showDialog<void>(
      context: context,
      builder: (c) {
        return ErrorDialog(message: message);
      }
  );
}
