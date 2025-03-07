import 'package:flutter/material.dart';

class CustomMaterialButton extends StatelessWidget {
  void Function()? onPressed;
  String? title;
  bool? outlined;
  CustomMaterialButton({super.key, this.onPressed, this.title, this.outlined});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      hoverColor: Theme.of(context).primaryColorLight,
      color: Theme.of(context).colorScheme.primary.withOpacity(outlined != null ? 0.5 : 1),
      shape: RoundedRectangleBorder(
        side: outlined != null ? BorderSide(color: Theme.of(context).colorScheme.primary) : BorderSide.none,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      onPressed: onPressed ?? () {
        Navigator.of(context).pop(); // Dismiss the alert
      },
      child: Text(
        title ?? "OK",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

