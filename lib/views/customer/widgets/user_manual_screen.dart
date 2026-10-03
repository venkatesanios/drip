import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class UserManualScreen extends StatelessWidget {
  final String url;
  const UserManualScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    print(url);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('User Manual')),
      body: PdfViewer.uri(
        Uri.parse(url),
        params: PdfViewerParams(
          textSelectionParams: const PdfTextSelectionParams(enabled: false),
          loadingBannerBuilder: (context, bytesDownloaded, totalBytes) =>
          const Center(child: CircularProgressIndicator()),
          errorBannerBuilder: (context, error, stackTrace, documentRef) =>
              Center(child: Text('Unable to load user manual\n$error')),
        ),
      ),
    );
  }
}