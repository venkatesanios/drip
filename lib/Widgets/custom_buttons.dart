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
      child: Text(title,style: const TextStyle(color: Colors.white),),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  void Function()? onPressed;
  CustomTextButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      onPressed: onPressed ?? () {
        Navigator.of(context).pop(); // Dismiss the alert
      },
      child: const Text(
        "OK",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

