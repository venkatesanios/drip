
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';


class UserManualScreen extends StatelessWidget {
  const UserManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('flutter_cached_pdfview Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PdfViewer.uri(
          Uri.parse('https://smartcomm-wms.com:5000/userManual/nova.pdf'),
        ),
      ),
    );
  }
}