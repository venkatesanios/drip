import 'package:flutter/material.dart';

class SetSerialScreen extends StatelessWidget {
  final data;
  const SetSerialScreen({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExpansionTile(
          title: Text("Smart"),
          subtitle: Text("Serial Number"),
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 25,
              decoration: const BoxDecoration(
                color: Color(0xffFFA300),
                borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(3))
              ),
              child: const Center(
                child: Text(
                  "Serial Number",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),
                ),
              ),
            ),
            Text("No Serial Number Found")
          ]
        )
      ],
    );
  }
}
