import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ConnectionErrorToast extends StatefulWidget {
  final int dataFetchingStatus;

  const ConnectionErrorToast({super.key, required this.dataFetchingStatus});

  @override
  _ConnectionErrorToastState createState() => _ConnectionErrorToastState();
}

class _ConnectionErrorToastState extends State<ConnectionErrorToast> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: widget.dataFetchingStatus == 1
          ? const SizedBox.shrink()
          : Container(
        key: const ValueKey("ConnectionError"),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red.shade300,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.dataFetchingStatus == 2 ? MdiIcons.progressAlert : MdiIcons.signalOff, color: Colors.white, size: 16,),
              const SizedBox(width: 10),
              Text(
                widget.dataFetchingStatus == 2 ? "Wait for communication..." : "No Communication",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}