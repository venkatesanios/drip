import 'dart:typed_data';

import 'package:better_download_saver/better_download_saver.dart';

import 'excel_builder.dart';

Future<bool> generateExcel(
    Map<String, dynamic> data,
    String name,
    ) async {
  try {
    final excel = buildLogsExcel(data);

    final fileBytes = excel.encode();

    if (fileBytes == null) {
      return false;
    }

    final Uint8List bytes = Uint8List.fromList(fileBytes);

    final saver = BetterDownloadSaver();

    final String? savedPath = await saver.saveToDownloads(
      fileName: '$name.xlsx',
      bytes: bytes,
      mimeType:
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );

    if (savedPath == null) {
      print('Excel save failed');
      return false;
    }

    print('Excel saved successfully: $savedPath');

    return true;
  } catch (e, stackTrace) {
    print('Error generating Excel: $e');
    print('StackTrace generating Excel: $stackTrace');

    return false;
  }
}