import 'package:flutter/material.dart';

class RadiusButtonStyle extends StatelessWidget {
  Color? backGroundColor;
  final String title;
  final void Function()? onPressed;
  RadiusButtonStyle({
    super.key,
    required this.onPressed,
    this.backGroundColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backGroundColor, // Button background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Add border radius
        ),
      ),
      child: Text(title,),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop(); // Dismiss the alert
      },
      child: const Text(
        "OK",
        style: TextStyle(color: Colors.blue),
      ),
    );
  }
}

