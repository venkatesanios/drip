import 'package:flutter/material.dart';

class ProgramLibrary extends StatelessWidget {
  const ProgramLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Program Library'),
      ),
      body: Column(
        children: [
          Text('Program Library')
        ],
      ),
    );
  }
}
