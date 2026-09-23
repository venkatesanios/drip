import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class UserManualScreen extends StatefulWidget {
  final String pdfUrl;

  const UserManualScreen({
    super.key,
    required this.pdfUrl,
  });

  @override
  State<UserManualScreen> createState() => _UserManualScreenState();
}

class _UserManualScreenState extends State<UserManualScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Manual'),
      ),
      body: SfPdfViewer.network(
        widget.pdfUrl,
        controller: _pdfViewerController,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        onDocumentLoaded: (details) {
          debugPrint('PDF loaded successfully');
        },
        onDocumentLoadFailed: (details) {
          debugPrint('PDF load failed');
          debugPrint('Error: ${details.error}');
          debugPrint('Description: ${details.description}');
        },
      ),
    );
  }
}