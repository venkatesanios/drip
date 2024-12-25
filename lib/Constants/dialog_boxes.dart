import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Constants/properties.dart';

import '../Widgets/custom_buttons.dart';


void simpleDialogBox({
  required BuildContext context,
  required String title,
  required String message,
}){
  showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 30,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: const [
            CustomTextButton()
          ],
        );
      }
  );
}