import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class UserManualScreen extends StatelessWidget {
  const UserManualScreen({super.key, required this.pdfUrl});
  final String pdfUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('User Manual'),
      ),
      body: PdfViewer.uri(
        Uri.parse(pdfUrl),
        params: const PdfViewerParams(
          margin: 16,
          backgroundColor: Colors.grey,
          enableTextSelection: false,
        ),
      ),
    );
  }
}